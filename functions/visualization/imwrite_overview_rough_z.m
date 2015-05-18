function imwrite_overview_rough_z(secA, secB)

if isempty(secB.overview.img)
	secB = load_overview(secB);
end
if isempty(secA.overview.img)
	secA = load_overview(secA);
end

[sA sA_R] = imwarp(secA.overview.img, secA.overview.alignment.tform);
[sB sB_R] = imwarp(secB.overview.img, secB.overview.rough_align_z.tforms);
[merge, merge_spatial_ref] = imfuse(sA, sA_R, sB, sB_R);
imwrite(merge, fullpath(renderpath.overview_rough_z, [secB.name '.tif']))
fprintf('<strong>Saving</strong> overview_rough_z for %s to renderpath\n', secB.name)
