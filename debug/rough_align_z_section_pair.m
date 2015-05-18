function [secA, secB] = rough_align_z_section_pair(secA, secB, manual)
% Align the overviews of two sections & create tile specific transforms
%
% Inputs:
%   secA: fixed section
%   secB: moving section

if nargin < 3
    manual = 0;
end

% Load overview for the sections
secB = load_overview(secB);
if isempty(secA.overview.img)
    secA = load_overview(secA);
end

% These parameters come from register_overviews
% They should be stored with the rough_z stats
params.overview_scale = 0.75;
params.overview_prescale = 1;
params.median_filter_radius = 6;
params.overview_to_tile_resolution_ratio = 0.07;
unmatched_params.SURF_MetricThreshold = 500;
unmatched_params.SURF_NumOctaves = 7;
unmatched_params.SURF_NumScaleLevels = 3;

% Preprocess the images (resize, crop, filter)
filteredA = overview_pre_process(secA.overview.img, params);
filteredB = overview_pre_process(secB.overview.img, params);

if manual
    % Manually select
    [ptsB, ptsA] = cpselect(filteredB, filteredA, 'Wait', true);
    stats.manual_fixed_matching_pts = ptsA;
    stats.manual_moving_matching_pts = ptsB;
    tform_moving = fitgeotrans(ptsB, ptsA, 'nonreflectivesimilarity');
else
    % Register overviews
    [tform_moving, stats] = surf_register(filteredA, filteredB, unmatched_params);
end

% Rescale the tform
% First to the appropriate level for display
s = params.overview_scale;
S = [s 0 0; 0 s 0; 0 0 1];
tform_rescaled_display = affine2d(S * tform_moving.T * S^-1);

% Adjust transform for initial transform
tform_final_overview = compose_tforms(secA.overview.alignment.tform, tform_rescaled_display);

% Then finish composing for the real scale
s = params.overview_to_tile_resolution_ratio;
S = [s 0 0; 0 s 0; 0 0 1];
tform_final_tile = affine2d(S * tform_final_overview.T * S^-1);

% Save to data structure
z_alignment.tforms = tform_final_overview;
z_alignment.rel_tforms = tform_rescaled_display;
z_alignment.rel_to = 'secA.overview.alignment.tform';
z_alignment.rel_to_sec = secA.num;
z_alignment.method = 'rough_align_z';
z_alignment.data = stats;
z_alignment.data.overview_scale = params.overview_scale;
secB.overview.rough_align_z = z_alignment;

% Display the transformed sections overlapping
% [fixed, fixed_spatial_ref] = imwarp(filteredA, secA.overview.alignment.tform);
% [moving, moving_spatial_ref] = imwarp(filteredB, tform_moving);
% [merge, merge_spatial_ref] = imfuse(fixed, fixed_spatial_ref, moving, moving_spatial_ref);
% figure();
% imshow(merge, merge_spatial_ref)

[fixed, fixed_spatial_ref] = imwarp(secA.overview.img, secA.overview.alignment.tform);
[moving, moving_spatial_ref] = imwarp(secB.overview.img, tform_rescaled_display);
[merge, merge_spatial_ref] = imfuse(fixed, fixed_spatial_ref, moving, moving_spatial_ref);
% resize_merge = imresize(merge, 0.10);
% render_dir = '/mnt/data0/tommy/matlab_renders';
% imwrite(resize_merge, fullfile(render_dir, 'overview_rough_z', [secB.wafer '_' num2str(secB.num) '.tif'])); 

figure();
imshow(merge, merge_spatial_ref)


% Assign the rough_align_z transform to every tile
num_tiles = size(secB.alignments.xy.tforms, 1);
rel_tforms_z_xy = {};
for i=1:num_tiles
    rel_tforms_z_xy{end+1} = tform_final_tile;
end
rel_tforms_z_xy = rel_tforms_z_xy';

% Compose this rough overview alignment to the xy alignment by tile
tforms_z_xy = cellfun(@(rough, rel) compose_tforms(rough, rel), secB.alignments.xy.tforms, rel_tforms_z_xy, 'UniformOutput', false);

% Save to data structure
z_xy_alignment.tforms = tforms_z_xy;
z_xy_alignment.rel_tforms = rel_tforms_z_xy;
z_xy_alignment.rel_to = 'xy';
z_xy_alignment.method = 'rough_align_z';
secB.alignments.rough_z_xy = z_xy_alignment;

secA.overview.img = [];
secB.overview.img = [];





