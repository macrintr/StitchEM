function [drawn_outlier_lines, secA, secB] = draw_rough_z_matches(secs, moving_sec_num)
% Produce matrix of paird section overviews

blue = uint8([0 0 255]);
green = uint8([0 255 0]);
red = uint8([255 0 0]);

% A is the fixed section
% B is the flexible section
% B also stores the correspondences pairs for both sections
secA = load_overview(secs{moving_sec_num-1}, secs{moving_sec_num}.overview.scale);
secB = load_overview(secs{moving_sec_num}, secs{moving_sec_num-1}.overview.scale);

outliersB = secB.alignments.rough_z.meta.stats.moving_matching_pts;
outliersA = secB.alignments.rough_z.meta.stats.fixed_matching_pts;

inliersB = secB.alignments.rough_z.meta.stats.moving_inliers;
inliersA = secB.alignments.rough_z.meta.stats.fixed_inliers;

% if isfield(secB.alignments.rough_z.meta.stats, 'user_adjusted')
%     inliers.A = [inliers.A; secB.z_matches.user_adjusted.A];
%     inliers.B = [inliers.B; secB.z_matches.user_adjusted.B];
% end

% These parameters come from register_overviews
% They should be stored with the rough_z stats
params.overview_scale = 0.75;
params.overview_prescale = 1;
params.crop_ratio = 0.9;
params.median_filter_radius = 6;

secA.overview.img = pre_process(secA.overview.img, params);
secB.overview.img = pre_process(secB.overview.img, params);

% convert tiles to RGB
A_rgb = repmat(secA.overview.img, [1,1,3]);
B_rgb = repmat(secB.overview.img, [1,1,3]);

% draw circles on tiles
A_drawn = draw_on_overview(A_rgb, inliersA, outliersA);
B_drawn = draw_on_overview(B_rgb, inliersB, outliersB);

paired = [A_drawn B_drawn]; % same row

% draw lines on the concatenation
width = size(secA.overview.img, 2);
inlier_lines = int32([inliersA inliersB(:,1)+width inliersB(:,2)]);
outlier_lines = int32([outliersA outliersB(:,1)+width outliersB(:,2)]);
outlier_shapeInserter = vision.ShapeInserter('Shape', 'Lines', 'BorderColor', 'Custom', 'CustomBorderColor', red);
inlier_shapeInserter = vision.ShapeInserter('Shape', 'Lines', 'BorderColor', 'Custom', 'CustomBorderColor', green);
drawn_outlier_lines = step(outlier_shapeInserter, paired, outlier_lines);
drawn_overview_pairs = step(inlier_shapeInserter, drawn_outlier_lines, inlier_lines);


filename = sprintf('%s_z_overview_matches.tif', secB.name);
imwrite(drawn_overview_pairs, fullfile(cachepath, filename));

end

function img = pre_process(im, params)
img = im;
% Resize
if params.overview_prescale ~= params.overview_scale
    img = imresize(img, (1 / params.overview_prescale) * params.overview_scale);
end

% Crop to center
crop_start = (1 - params.crop_ratio) / 2;
crop_end = params.crop_ratio;
img = imcrop(img, [size(im, 2) * crop_start, size(img, 1) * crop_start, size(img, 2) * crop_end, size(img, 1) * crop_end]);

% Apply median filter
if params.median_filter_radius > 0
    img = medfilt2(img, [params.median_filter_radius params.median_filter_radius]);
end

end

function drawing = draw_on_overview(img, inliers, outliers)
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
color = green;

% build inlier circles
in_num = size(inliers, 1);
in_circles = int32([inliers ones(in_num, 1)*radius]);
in_shapeInserter = vision.ShapeInserter('Shape', 'Circles', 'BorderColor', 'Custom', 'CustomBorderColor', color);

% build outlier circles
out_num = size(outliers, 1);
out_circles = int32([outliers ones(out_num, 1)*radius]);
out_shapeInserter = vision.ShapeInserter('Shape', 'Circles', 'BorderColor', 'Custom', 'CustomBorderColor', red);

% draw the circles on the tile
drawing = step(out_shapeInserter, img, out_circles);
drawing = step(in_shapeInserter, drawing, in_circles);

end