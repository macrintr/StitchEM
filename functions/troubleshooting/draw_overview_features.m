function drawing = draw_overview_features(img, inliers, outliers)
% Draw inlier & outlier circles on an overview
%
% Inputs:
%   img: RGB matrix
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

img = repmat(img, [1,1,3]);

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