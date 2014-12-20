function mov = imshow_matches2(secA, secB, matches, alignment)
% Display image of transformed tiles overlaid with common feature marked
%
% Input:
%   secA: sec struct for the first tile
%   secB: sec struct for the second tile (sould be the same as secA if xy)
%   alignment: matches struct of a section (sec.xy_matches or sec.z_matches)
%   id_list: vector of ints corresponding to id of match pair to display
%
% Output:
%   none - side-by-side images will be displayed as frames in a movie

% Load the two tiles, if not loaded already
secA = smart_load_tile(secA);
secB = smart_load_tile(secB);

crop_dist = 300;

% Get all the tforms
tformsA = secA.alignments.(alignment).tforms;
tformsB = secB.alignments.(alignment).tforms;

% Transform the matches
for i=1:length(tformsA)
    matches.globalA(matches.tileA == i, :) = transformPointsForward(tformsA{i}, matches.localA(matches.tileA == i, :));
end
for i=1:length(tformsB)
    matches.globalB(matches.tileB == i, :) = transformPointsForward(tformsB{i}, matches.localB(matches.tileB == i, :));
end

% Transform the tiles & spatial_refs, draw circles
[tileA_warp, RsA] = warp_and_circle_tiles(secA.tiles.full.img, tformsA, matches, 'A', secA.tile_sizes);
[tileB_warp, RsB] = warp_and_circle_tiles(secB.tiles.full.img, tformsB, matches, 'B', secB.tile_sizes);

mov = [];

for id=1:length(matches)
    % Grab the point of interest
    point = matches(i);
       
    % Crop images
    rectA = [point.globalA(1) - RsA.XWorldLimits(1) - crop_dist/2, point.globalA(2) - RsA.YWorldLimits(1) - crop_dist/2, crop_dist, crop_dist];
    rectB = [point.globalB(1) - RsB.XWorldLimits(1) - crop_dist/2, point.globalB(2) - RsB.YWorldLimits(1) - crop_dist/2, crop_dist, crop_dist];
    tileA_cropped = imcrop(tileA_warp{point.tileA}, rectA);
    tileB_cropped = imcrop(tileB_warp{point.tileB}, rectB);
    
    sizes = [size(tileA_cropped); size(tileB_cropped)];
    max_size = max([sizes(:); crop_dist]);
    tileA_padded = pad_undersized_image(tileA_cropped, rectA, RsA, max_size);
    tileB_padded = pad_undersized_image(tileB_cropped, rectB, RsB, max_size);
    
    h = size(tileA_padded, 1);
    img = cat(2, tileA_padded, zeros(h, 10, 3), tileB_padded);
    text = ['ID ' num2str(point.id)];
    position = [10 10];
    RGB = insertText(img, position, text, 'FontSize', 18);
    mov = cat(4, mov, RGB);
end

implay(mov, 1);

function sec = smart_load_tile(sec)
% Load tile images if they haven't been loaded, yet

if ~isfield(sec.tiles, 'full')
    sec.tiles.full.img = imload_section_tiles(sec, 1.0);
end

if size(sec.tiles.full.img{1}, 3) < 3
    for i=1:length(sec.tiles.full.img)
        sec.tiles.full.img{i} = repmat(sec.tiles.full.img{i}, [1,1,3]);
    end
end

function tile_cropped = pad_undersized_image(tile_cropped, rect, Rs, max_size)

if rect(1) < 0
    left = ones(size(tile_cropped, 1), max_size - size(tile_cropped, 2), 3);
    tile_cropped = cat(2, left, tile_cropped);
end
if rect(2) < 0
    top = ones(max_size - size(tile_cropped, 1), size(tile_cropped, 2), 3);
    tile_cropped = cat(1, top, tile_cropped);
end
if rect(1) + rect(3) > Rs.ImageSize(2)
    right = ones(size(tile_cropped, 1), max_size - size(tile_cropped, 2), 3);
    tile_cropped = cat(2, tile_cropped, right);
end
if rect(2) + rect(4) > Rs.ImageSize(1)
    bottom = ones(max_size - size(tile_cropped, 1), size(tile_cropped, 2), 3);
    tile_cropped = cat(1, tile_cropped, bottom);
end

function [tile_set, Rs] = warp_and_circle_tiles(tiles, tforms, matches, section_letter, tile_sizes)
% Apply tform to tiles and matches, then draw circles on tiles
%
% Inputs:
%   sec: section struct
%   matches: matches dataset
%   section_letter: 'A' or 'B'
%
% Outputs:
%   matches: Updated so that global points are transformed to new space
%   tile_set: cell array of tform applied tiles with match circles drawn

tile_type = ['tile' section_letter];
global_type = ['global' section_letter];

tile_set = cell(length(tile_sizes), 1);
Rs = cell(length(tile_sizes), 1);

radius = 40;
green = uint8([0 255 0]);
shapeInserter = vision.ShapeInserter('Shape', 'Circles', 'BorderColor', 'Custom', 'CustomBorderColor', green);

for tile_num = unique(matches.(tile_type))'
    % Collect the relevant transform & points
    tform = tforms{tile_num};
    points = matches.(global_type)(matches.(tile_type) == tile_num, :);
        
    % Transform the tile
    tile_set{tile_num} = imwarp(tiles{tile_num}, tform);
    
    % Transform the spatial ref
    initial_Rs = imref2d(tile_sizes{tile_num});
    Rs{tile_num} = tform_spatial_ref(initial_Rs, tform);
    
    % Draw circles on the tiles
    circle = int32([points ones(length(points), 1)*radius]);
    tile_set{tile_num} = step(shapeInserter, tile_set{tile_num}, circle);
end
