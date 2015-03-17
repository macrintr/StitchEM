function [composite, percentage] = image_compare(imgA, imgB, tformA, tformB)

if nargin < 3
    tformA = affine2d();
    tformB = affine2d();
end

imgB = histeq(imgB, imhist(imgA));

% Get an initial bounding box based on the tile size
bbA = sz2bb(size(imgA));
bbB = sz2bb(size(imgB));

% Apply alignment transform
bbA = tformA.transformPointsForward(bbA);
bbB = tformB.transformPointsForward(bbB);
Iab = intersect_polys(bbA, bbB);

inv_bbA = tformA.transformPointsInverse(Iab);
inv_bbB = tformB.transformPointsInverse(Iab);

% Find limits of the axis-aligned bounding box of the region
[XLimsA, YLimsA] = bb2lims(inv_bbA);
[XLimsB, YLimsB] = bb2lims(inv_bbB);

% Convert intrinsic limits to subscripts
[IA, JA] = intrinsicToSubscripts(XLimsA, YLimsA, size(imgA));
[IB, JB] = intrinsicToSubscripts(XLimsB, YLimsB, size(imgB));

% Extract region from image
imgA_region = imgA(IA(1):IA(2), JA(1):JA(2));
imgB_region = imgB(IB(1):IB(2), JB(1):JB(2));

% Build tforms to account for the origin shift from the cropping
tformA_crop = affine2d(tformA.T * [1 0 0; 0 1 0; IA(1) JA(1) 1]);
tformB_crop = affine2d(tformB.T * [1 0 0; 0 1 0; IB(1) JB(1) 1]);

% Transform cropped images
[imgA_cropped, imgA_R] = imwarp(imgA_region, tformA_crop);
[imgB_cropped, imgB_R] = imwarp(imgB_region, tformB_crop);

% [imgA_cropped, imgA_R] = imwarp(imgA, tformA);
% [imgB_cropped, imgB_R] = imwarp(imgB, tformB);

% Merge with imfuse
% [composite, merge_R] = imfuse(imgA_cropped, imgA_R, imgB_cropped, imgB_R, 'ColorChannels', [1 2 0]);

% figure;
% imshow(composite);

% Merge spatial refs
merge_R = merge_spatial_refs({imgA_R, imgB_R});

% Pad images
imgA = images.spatialref.internal.resampleImageToNewSpatialRef(imgA_cropped, imgA_R, merge_R, 'bicubic', 0);
imgB = images.spatialref.internal.resampleImageToNewSpatialRef(imgB_cropped, imgB_R, merge_R, 'bicubic', 0);

% figure;
% imshow(imgA, merge_R);
% figure;
% imshow(imgB, merge_R);

tolerance = 1.1;
black_mask = (imgA == 0 | imgB == 0);
white_mask = (imgA == 255 | imgB == 255);

red_mask = imgA > tolerance * imgB;
green_mask = imgB > tolerance * imgA;
blue_mask = ~(red_mask + green_mask) .* ~(black_mask + white_mask);

composite = cat(3, red_mask, green_mask, blue_mask) * 255;

% figure;
% imshow(composite);

red = sum(red_mask(:));
green = sum(green_mask(:));
blue = sum(blue_mask(:));
percentage = blue / (red + green + blue);