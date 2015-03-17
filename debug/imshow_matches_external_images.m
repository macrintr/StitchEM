function mov = imshow_matches_external_images(secA, secB, matches, scale)
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
imgA = imread(secA.filepath);
imgB = imread(secB.filepath);

imgA = repmat(imgA, [1,1,3]);
imgB = repmat(imgB, [1,1,3]);

matches.localA = matches.localA * scale;
matches.localB = matches.localB * scale;

p1 = 40;
p2 = 10;
crop_dist = 300;
green = uint8([0 255 0]);
shapeInserter = vision.ShapeInserter('Shape', 'Lines', 'BorderColor', 'Custom', 'CustomBorderColor', green);

mov = [];

for i=1:length(matches)
    % Grab the point of interest
    point = matches(i, :);    
    
    % Crop images
    rectA = [point.localA(1) - crop_dist/2, point.localA(2) - crop_dist/2, crop_dist, crop_dist];
    rectB = [point.localB(1) - crop_dist/2, point.localB(2) - crop_dist/2, crop_dist, crop_dist];
    tileA_cropped = imcrop(imgA, rectA);
    tileB_cropped = imcrop(imgB, rectB);
    
%     sizes = [size(tileA_cropped); size(tileB_cropped)];
%     max_size = max([sizes(:); crop_dist]);
    max_size = crop_dist + 2;
    tileA_padded = pad_image(tileA_cropped, rectA, max_size);
    tileB_padded = pad_image(tileB_cropped, rectB, max_size);
    
    c = max_size/2 - 1;
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
    text = ['ptA  ' num2str(point.globalA)];
    position = [10 h+10];
    img = insertText(img, position, text, 'FontSize', 14);
    text = ['ptB  ' num2str(point.globalB)];
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

implay(mov, 1);

function tile_cropped = pad_image(tile_cropped, rect, max_size)

if rect(1) < 0
    left = ones(size(tile_cropped, 1), max_size - size(tile_cropped, 2), 3);
    tile_cropped = cat(2, left, tile_cropped);
end
if rect(2) < 0
    top = ones(max_size - size(tile_cropped, 1), size(tile_cropped, 2), 3);
    tile_cropped = cat(1, top, tile_cropped);
end
if rect(1) + rect(3) > max_size
    right = ones(size(tile_cropped, 1), max_size - size(tile_cropped, 2), 3);
    tile_cropped = cat(2, tile_cropped, right);
end
if rect(2) + rect(4) > max_size
    bottom = ones(max_size - size(tile_cropped, 1), size(tile_cropped, 2), 3);
    tile_cropped = cat(1, tile_cropped, bottom);
end
