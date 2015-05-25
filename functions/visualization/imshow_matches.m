function mov = imshow_matches(secA, secB, matches, scale)
% Display image of transformed tiles overlaid with common feature marked
%
% Input:
%   secA: sec struct for the first tile
%   secB: sec struct for the second tile (sould be the same as secA if xy)
%   matches: matches struct of a section (sec.xy_matches or sec.z_matches)
%   scale: resolution of the image surrounding the image (1x: full
%   resolution)
%
% Output:
%   mov: movie object - can be played with implay(mov, 1)

if nargin < 4
    scale = 0.3;
end

% Load the two tiles, if not loaded already
secA = smart_load_tile(secA, scale);
secB = smart_load_tile(secB, scale);

matches.localA = matches.localA * scale;
matches.localB = matches.localB * scale;

p1 = 40;
p2 = 10;
crop_dist = 300;
green = uint8([0 255 0]);
shapeInserter = vision.ShapeInserter('Shape', 'Lines', 'BorderColor', 'Custom', 'CustomBorderColor', green);

% tileA_warp = cell(secA.num_tiles, 1);
% tileB_warp = cell(secB.num_tiles, 1);

mov = [];

for i=1:length(matches)
    % Grab the point of interest
    point = matches(i, :);    
    
    % Complete tile transforms for the alignment step
%     tformA = secA.alignments.(alignment).tforms{point.tileA};
%     tformB = secB.alignments.(alignment).tforms{point.tileB};
    
    % Transform the global points to this alignment step
    % (global_points, while calculated in this alignment step, actually are
    % coordinates in the space of the previous alignment step. So z alignment
    % global_points exist in the rough_z coordinate space.)
%     point.globalA = transformPointsForward(tformA, point.localA);
%     point.globalB = transformPointsForward(tformB, point.localB);
    
    % Initialize the spatial refs for the tiles
%     initial_RsA = imref2d(secA.tile_sizes{point.tileA} * scale);
%     initial_RsB = imref2d(secB.tile_sizes{point.tileB} * scale);
    
    % Transform the spatial refs for the tiles
%     RsA = tform_spatial_ref(initial_RsA, tformA);
%     RsB = tform_spatial_ref(initial_RsB, tformB);
    
    % Transform images (check that we haven't done this already)
%     if isempty(tileA_warp{point.tileA})
%         tileA_warp{point.tileA} = imwarp(secA.tiles.demo.img{point.tileA}, tformA);
%     end
%     if isempty(tileB_warp{point.tileB})
%         tileB_warp{point.tileB} = imwarp(secB.tiles.demo.img{point.tileB}, tformB);
%     end
    
    % Crop images
%     rectA = [point.globalA(1) - RsA.XWorldLimits(1) - crop_dist/2, point.globalA(2) - RsA.YWorldLimits(1) - crop_dist/2, crop_dist, crop_dist];
%     rectB = [point.globalB(1) - RsB.XWorldLimits(1) - crop_dist/2, point.globalB(2) - RsB.YWorldLimits(1) - crop_dist/2, crop_dist, crop_dist];
    rectA = [point.localA(1) - crop_dist/2, point.localA(2) - crop_dist/2, crop_dist, crop_dist];
    rectB = [point.localB(1) - crop_dist/2, point.localB(2) - crop_dist/2, crop_dist, crop_dist];
    tileA_cropped = imcrop(secA.tiles.demo.img{point.tileA}, rectA);
    tileB_cropped = imcrop(secB.tiles.demo.img{point.tileB}, rectB);
    
    sizes = [size(tileA_cropped); size(tileB_cropped)];
    max_size = max([sizes(:); crop_dist]);
    tileA_padded = pad_image(tileA_cropped, rectA, max_size);
    tileB_padded = pad_image(tileB_cropped, rectB, max_size);
    
    c = max_size/2;
    crosshairs = int32([c - p1, c, c - p2, c; c + p2, c, c + p1, c; c, c - p1, c, c - p2; c, c + p2, c, c + p1]);
    crosshairs = int32(crosshairs);
    tileA_circled = step(shapeInserter, tileA_padded, crosshairs);
    tileB_circled = step(shapeInserter, tileB_padded, crosshairs);
           
    h = size(tileA_circled, 1);
    img = cat(2, tileA_circled, zeros(h, 10, 3), tileB_circled);
    l = size(img, 2);
    img = cat(1, img, zeros(80, l, 3));
    text = ['ID ' num2str(point.id)];
    position = [10 10];
    img = insertText(img, position, text, 'FontSize', 18);
    text = ['ptA  ' num2str(point.tformsA)];
    position = [10 h+10];
    img = insertText(img, position, text, 'FontSize', 14);
    text = ['ptB  ' num2str(point.tformsB)];
    position = [l/2+20 h+10];
    img = insertText(img, position, text, 'FontSize', 14);    
    text = ['scale  ' num2str(scale)];
    position = [10 h+40];
    img = insertText(img, position, text, 'FontSize', 14); 
    text = ['dist  ' num2str(point.dist)];
    position = [l/2+20 h+40];
    img = insertText(img, position, text, 'FontSize', 14);     
    if size(img, 1) < size(mov, 1)
        bottom = ones(size(mov, 1) - size(img, 1), size(img, 2), 3);
        img = cat(1, img, bottom);
    end
    if size(img, 1) > size(mov, 1)
        img = img(1:end-1,:,:);
    end
    if size(img, 2) < size(mov, 2)
        right = ones(size(img, 1), size(mov, 2) - size(img, 2), 3);
        img = cat(2, img, right);
    end
    if size(img, 2) > size(mov, 2)
        img = img(:,1:end-1,:);
    end
    mov = cat(4, mov, img);
end

% implay(mov, 1);

function sec = smart_load_tile(sec, scale)
% Load tile images if they haven't been loaded, yet

if ~isfield(sec.tiles, 'demo')
    sec.tiles.demo.img = imload_section_tiles(sec, scale);
end

if size(sec.tiles.demo.img{1}, 3) < 3
    for i=1:length(sec.tiles.demo.img)
        sec.tiles.demo.img{i} = repmat(sec.tiles.demo.img{i}, [1,1,3]);
    end
end

function tile_cropped = pad_image(tile_cropped, rect, max_size)

if rect(1) < 0
    left = ones(size(tile_cropped, 1), max_size - size(tile_cropped, 2), 3);
    tile_cropped = cat(2, left, tile_cropped);
end
if rect(2) < 0
    top = ones(max_size - size(tile_cropped, 1), size(tile_cropped, 2), 3);
    tile_cropped = cat(1, top, tile_cropped);
end
if rect(1) + rect(3) > size(tile_cropped, 2)
    right = ones(size(tile_cropped, 1), max_size - size(tile_cropped, 2), 3);
    tile_cropped = cat(2, tile_cropped, right);
end
if rect(2) + rect(4) > size(tile_cropped, 1)
    bottom = ones(max_size - size(tile_cropped, 1), size(tile_cropped, 2), 3);
    tile_cropped = cat(1, tile_cropped, bottom);
end
