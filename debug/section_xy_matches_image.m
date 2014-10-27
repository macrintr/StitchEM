function sec_stitch = section_xy_matches_image(sec)
% Save image of uncropped tiles as section with features & matches marked.
%
% Inputs:
%	section struct
%
% Outputs:
%	large image of all the tiles stitched
%   tiles are uncropped
%
% UNTESTED!
%
% Thomas Macrina
% tmacrina@princeton.edu
% October 2014

radius = 80;
sec_row = [];
sec_stitch = [];
lines = [];
yellow = uint8([255 255 0]);
green = uint8([0 255 0]);
red = uint8([255 0 0]);
blue = uint8([0 0 255]);

for n = 1:sec.num_tiles
    [row, col] = find(sec.grid==n);

    tile = sec.tiles.full.img{n};
    tile_rgb = repmat(tile, [1,1,3]); % convert tile to RGB
    
    A_rows = sec.xy_matches.A.tile==n;
    A_coords = sec.xy_matches.A(A_rows, 'local_points').local_points;
    A_num = size(A_coords, 1);
    A_circles = int32([A_coords ones(A_num, 1)*radius]);
    A_shapeInserter = vision.ShapeInserter('Shape', 'Circles', 'BorderColor', 'Custom', 'CustomBorderColor', yellow);
    
    B_rows = sec.xy_matches.B.tile==n;
    B_coords = sec.xy_matches.B(B_rows, 'local_points').local_points;
    B_num = size(B_coords, 1);
    B_circles = int32([B_coords ones(B_num, 1)*radius]);
    B_shapeInserter = vision.ShapeInserter('Shape', 'Circles', 'BorderColor', 'Custom', 'CustomBorderColor', green);
    
    O_rows = 
    
    tile_circles = step(A_shapeInserter, tile_rgb, A_circles);
    tile_circles = step(B_shapeInserter, tile_circles, B_circles);
    
    if col==1
        sec_row = [tile_circles];
    elseif col==4
        sec_row = [sec_row tile_circles];
        sec_stitch = [sec_stitch; sec_row];
    else
        sec_row = [sec_row tile_circles];
    end
    
end
