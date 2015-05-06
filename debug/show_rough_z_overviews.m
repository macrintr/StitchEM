function show_rough_z_overviews(secA, secB)

if isempty(secB.overview.img)
	secB = load_overview(secB, secB.overview.scale);
end
if isempty(secA.overview.img)
	secA = load_overview(secA, secA.overview.scale);
end

imgA = imwarp(secA.overview.img, secA.overview.rough_align_z.tforms);
imgB = imwarp(secB.overview.img, secB.overview.rough_align_z.tforms);
img = imfuse(imgA, imgB);
imshow(img);
% print('rough_z_overviews', '-dpng')
% imwrite(img, 'rough_z_overviews.png');
