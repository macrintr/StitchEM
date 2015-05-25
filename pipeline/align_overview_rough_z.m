function secB = align_overview_rough_z(secA, secB, manual)
% Align the overviews of two sections & create tile specific transforms
%
% Inputs:
%   secA: fixed section
%   secB: moving section

if nargin < 3
    manual = 0;
end

% These parameters come from register_overviews
% They should be stored with the rough_z stats
params.overview_scale = 0.78;
params.overview_prescale = 1;
params.median_filter_radius = 6;
params.overview_crop_ratio = 1.0;
params.overview_cropping = [0 0 1 1];

SURF_params.SURF_MetricThreshold = 500;
SURF_params.SURF_NumOctaves = 7;
SURF_params.SURF_NumScaleLevels = 3;

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
    [tform_moving, stats] = surf_register(filteredA, filteredB, SURF_params);
end

% Rescale the tform
% First to the appropriate level for display
s = params.overview_scale;
S = [s 0 0; 0 s 0; 0 0 1];
tform_rescaled_display = affine2d(S * tform_moving.T * S^-1);

% Adjust transform for initial transform
tform_final_overview = compose_tforms(secA.overview.alignments.initial.tform, tform_rescaled_display);

% Save to data structure
z_alignment.tform = tform_final_overview;
z_alignment.rel_tform = tform_rescaled_display;
z_alignment.rel_to = 'secA.overview.alignment.tform';
z_alignment.rel_to_sec = secA.num;
z_alignment.method = 'align_overview_rough_z';
z_alignment.data = stats;
z_alignment.data.overview_scale = params.overview_scale;
secB.overview.alignments.rough_z = z_alignment;





