function tile_pair = draw_xy_matches(sec, A_idx, B_idx)
% Produce matrix of tile pair

blue = uint8([0 0 255]);
green = uint8([0 255 0]);
red = uint8([255 0 0]);

inliers = sec.xy_matches;
outliers = sec.xy_matches.outliers;
if isfield(sec.xy_matches, 'user_adjusted')
    inliers.A = [inliers.A; sec.xy_matches.user_adjusted.A];
    inliers.B = [inliers.B; sec.xy_matches.user_adjusted.B];
end
match_inliers = [inliers.A.local_points inliers.A.tile inliers.B.local_points inliers.B.tile];
match_outliers= [outliers.A.local_points outliers.A.tile outliers.B.local_points outliers.B.tile];

sec.tiles.full.img = imload_section_tiles(sec, 1.0);

A_tile = sec.tiles.full.img{A_idx};
B_tile = sec.tiles.full.img{B_idx};

% convert tiles to RGB
A_tile_rgb = repmat(A_tile, [1,1,3]);
B_tile_rgb = repmat(B_tile, [1,1,3]);

% draw circles on tiles
inlier_pair_coords = match_inliers(match_inliers(:,3)==A_idx & match_inliers(:,6)==B_idx, :);
outlier_pair_coords = match_outliers(match_outliers(:,3)==A_idx & match_outliers(:,6)==B_idx, :);
A_drawn_tile = draw_on_tile(A_tile_rgb, inlier_pair_coords(:,1:2), outlier_pair_coords(:,1:2), true);
B_drawn_tile = draw_on_tile(B_tile_rgb, inlier_pair_coords(:,4:5), outlier_pair_coords(:,4:5), false);

% concatenate the tiles
[A_row, A_col] = find(sec.grid==A_idx);
[B_row, B_col] = find(sec.grid==B_idx);
if A_row == B_row
    paired = [A_drawn_tile B_drawn_tile]; % same row
    x_adj = 1;
    y_adj = 0;
elseif A_col == B_col
    paired = [A_drawn_tile; B_drawn_tile]; % same col
    x_adj = 0;
    y_adj = 1;
else
    disp();
end

% draw lines on the concatenation
inlier_lines = int32([inlier_pair_coords(:,1:2) inlier_pair_coords(:,4)+x_adj*8000 inlier_pair_coords(:,5)+y_adj*8000]);
outlier_lines = int32([outlier_pair_coords(:,1:2) outlier_pair_coords(:,4)+x_adj*8000 outlier_pair_coords(:,5)+y_adj*8000]);
inlier_shapeInserter = vision.ShapeInserter('Shape', 'Lines', 'BorderColor', 'Custom', 'CustomBorderColor', green);
outlier_shapeInserter = vision.ShapeInserter('Shape', 'Lines', 'BorderColor', 'Custom', 'CustomBorderColor', red);
lined_tiles = step(inlier_shapeInserter, paired, inlier_lines);
tile_pair = step(outlier_shapeInserter, lined_tiles, outlier_lines);

function annotated_tile = draw_on_tile(tile, inliers, outliers, A)
% Draw inlier & outlier circles on a tile
%
% Inputs:
%   tile: RGB matrix
%   inliers: nx2 float matrix with centers of inlier features
%   outliers: mx2 float matrix with centers of outlier features
%   A: boolean indicating if this is the "fixed" or A tile
%
% Outliers:
%   annotated_tile: RGB matrix of the tile with inlier & outlier circles

radius = 80;
green = uint8([0 255 0]);
yellow = uint8([255 255 0]);
red = uint8([255 0 0]);
if A color=green; else color = yellow; end

% build inlier circles
in_num = size(inliers, 1);
in_circles = int32([inliers ones(in_num, 1)*radius]);
in_shapeInserter = vision.ShapeInserter('Shape', 'Circles', 'BorderColor', 'Custom', 'CustomBorderColor', color);

% build outlier circles
out_num = size(outliers, 1);
out_circles = int32([outliers ones(out_num, 1)*radius]);
out_shapeInserter = vision.ShapeInserter('Shape', 'Circles', 'BorderColor', 'Custom', 'CustomBorderColor', red);

% draw the circles on the tile
annotated_tile = step(in_shapeInserter, tile, in_circles);
annotated_tile = step(out_shapeInserter, annotated_tile, out_circles);
