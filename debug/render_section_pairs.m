function render_section_pairs(secA, secB, display_rendering)
% Create aligned & stitched section from section cell series index
alignment = 'stack_z';

tformsA = secA.alignments.(alignment).tforms;
[sA sA_R] = render_section(secA, tformsA, 'scale', 0.05);

tformsB = secB.alignments.(alignment).tforms;
[sB sB_R] = render_section(secB, tformsB, 'scale', 0.05);

[merge, merge_spatial_ref] = imfuse(sA, sA_R, sB, sB_R);
if display_rendering
    figure();
    imshow(merge, merge_spatial_ref);
end

% filename = sprintf('%s/%s_fine_align_z_xy_%d_%d.tif', secA.wafer, secB.wafer, secB.num, secA.num);
% imwrite(merge, fullfile(cachepath, filename));