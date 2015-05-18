function show_rough_z_overviews(secA, secB)

if isempty(secB.overview.img)
	secB = load_overview(secB);
end
if isempty(secA.overview.img)
	secA = load_overview(secA);
end

[sA sA_R] = imwarp(secA.overview.img, secA.overview.alignment.tform);
[sB sB_R] = imwarp(secB.overview.img, secB.overview.rough_align_z.tforms);
[merge, merge_spatial_ref] = imfuse(sA, sA_R, sB, sB_R);
figure
imshow(merge);
% print('rough_z_overviews', '-dpng')
% imwrite(img, 'rough_z_overviews.png');
