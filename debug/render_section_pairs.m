function render_section_pairs(secA, secB, aA, aB)
% Create aligned & stitched section from section cell series index
if nargin == 2
    aA = 'z'; 
    aB = 'z';
elseif nargin == 3
    aB = aA;
end

tformsA = secA.alignments.(aA).tforms;
[sA sA_R] = render_section(secA, tformsA, 'scale', 0.05);

tformsB = secB.alignments.(aB).tforms;
[sB sB_R] = render_section(secB, tformsB, 'scale', 0.05);

[merge, merge_spatial_ref] = imfuse(sA, sA_R, sB, sB_R);
figure();
imshow(merge, merge_spatial_ref);

% resize_merge = imresize(merge, 0.50);
% render_dir = '/mnt/data0/tommy/matlab_renders';
% imwrite(resize_merge, fullfile(render_dir, 'rough_z', [secB.wafer '_' num2str(secB.num) '.tif'])); 

% filename = sprintf('%s/%s_fine_align_z_xy_%d_%d.tif', secA.wafer, secB.wafer, secB.num, secA.num);
% imwrite(merge, fullfile(cachepath, filename));