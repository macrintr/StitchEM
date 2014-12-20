function mov = imshow_matches(secA, secB, matches, alignment)
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

p1 = 40;
p2 = 10;
crop_dist = 300;
green = uint8([0 255 0]);
shapeInserter = vision.ShapeInserter('Shape', 'Lines', 'BorderColor', 'Custom', 'CustomBorderColor', green);

tileA_warp = cell(secA.num_tiles, 1);
tileB_warp = cell(secB.num_tiles, 1);

mov = [];

for i=1:length(matches)
    % Grab the point of interest
    point = matches(i, :);
    
    % Complete tile transforms for the alignment step
    tformA = secA.alignments.(alignment).tforms{point.tileA};
    tformB = secB.alignments.(alignment).tforms{point.tileB};
    
    % Transform the global points to this alignment step
    % (global_points, while calculated in this alignment step, actually are
    % coordinates in the space of the previous alignment step. So z alignment
    % global_points exist in the rough_z coordinate space.)
    point.globalA = transformPointsForward(tformA, point.localA);
    point.globalB = transformPointsForward(tformB, point.localB);
    
    % Initialize the spatial refs for the tiles
    initial_RsA = imref2d(secA.tile_sizes{point.tileA});
    initial_RsB = imref2d(secA.tile_sizes{point.tileB});
    
    % Transform the spatial refs for the tiles
    RsA = tform_spatial_ref(initial_RsA, tformA);
    RsB = tform_spatial_ref(initial_RsB, tformB);
    
    % Transform images (check that we haven't done this already)
    if isempty(tileA_warp{point.tileA})
        tileA_warp{point.tileA} = imwarp(secA.tiles.full.img{point.tileA}, tformA);
    end
    if isempty(tileB_warp{point.tileB})
        tileB_warp{point.tileB} = imwarp(secB.tiles.full.img{point.tileB}, tformB);
    end
    
    % Crop images
    rectA = [point.globalA(1) - RsA.XWorldLimits(1) - crop_dist/2, point.globalA(2) - RsA.YWorldLimits(1) - crop_dist/2, crop_dist, crop_dist];
    rectB = [point.globalB(1) - RsB.XWorldLimits(1) - crop_dist/2, point.globalB(2) - RsB.YWorldLimits(1) - crop_dist/2, crop_dist, crop_dist];
    tileA_cropped = imcrop(tileA_warp{point.tileA}, rectA);
    tileB_cropped = imcrop(tileB_warp{point.tileB}, rectB);
    
    sizes = [size(tileA_cropped); size(tileB_cropped)];
    max_size = max([sizes(:); crop_dist]);
    tileA_padded = pad_image(tileA_cropped, rectA, RsA, max_size);
    tileB_padded = pad_image(tileB_cropped, rectB, RsB, max_size);
    
    c = max_size/2;
    crosshairs = int32([c - p1, c, c - p2, c; c + p2, c, c + p1, c; c, c - p1, c, c - p2; c, c + p2, c, c + p1]);
    crosshairs = int32(crosshairs);
    tileA_circled = step(shapeInserter, tileA_padded, crosshairs);
    tileB_circled = step(shapeInserter, tileB_padded, crosshairs);
           
    h = size(tileA_circled, 1);
    img = cat(2, tileA_circled, zeros(h, 10, 3), tileB_circled);
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

function tile_cropped = pad_image(tile_cropped, rect, Rs, max_size)

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
