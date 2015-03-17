function secB = select_rough_z_matches(secs, secB_num)
% Manually select new rough Z matching points & update section transform

secB = secs{secB_num};
secA = secs{secB_num-1};

tform_fixed = secA.overview.alignment.tform;

% Load the overview images
secA = load_overview(secA, secA.overview.scale);
secB = load_overview(secB, secB.overview.scale);

% These parameters come from register_overviews
% They should be stored with the rough_z stats
params.overview_scale = 0.75;
params.overview_prescale = 1;
params.median_filter_radius = 6;
params.overview_to_tile_resolution_ratio = 0.07;

% Crop and downsample the images for higher quality, more stable features
filteredA = overview_pre_process(secA.overview.img, params);
filteredB = overview_pre_process(secB.overview.img, params);

% Match features and generate the transform at the downsample
[ptsB, ptsA] = cpselect(filteredB, filteredA, 'Wait', true);
stats.manual_fixed_matching_pts = ptsA;
stats.manual_moving_matching_pts = ptsB;
moving_tform = fitgeotrans(ptsB, ptsA, 'nonreflectivesimilarity');
% stats.manual_fixed_inliers = fixed_inliers;
% stats.manual_moving_inliers = moving_inliers;

% Rescale the tform
% First to the appropriate level for display
s = 1/params.overview_scale;
S = [s 0 0; 0 s 0; 0 0 1];
tform_rescaled_display = affine2d(S^-1 * moving_tform.T * S);

% Then finish composing for the real scale
s = 1/(secB.overview.scale * params.overview_to_tile_resolution_ratio);
S = [s 0 0; 0 s 0; 0 0 1];
tform_rescaled_real = affine2d(S^-1 * tform_rescaled_display.T * S);

% Adjust transform for initial transforms (rare)
tform_rescaled_final = affine2d(secA.overview.alignment.tform.T * tform_rescaled_real.T);

% Save to data structure
z_alignment.rel_tforms = tform_rescaled_final;
z_alignment.rel_to = 'None';
z_alignment.rel_to_sec = secA.num;
z_alignment.method = 'rough_align_z';
z_alignment.data = stats;
z_alignment.data.overview_scale = secB.overview.scale;
secB.overview.rough_align_z = z_alignment;

% Display the transformed sections overlapping
[fixed, fixed_spatial_ref] = imwarp(filteredA, secA.overview.alignment.tform);
[moving, moving_spatial_ref] = imwarp(filteredB, moving_tform);
[merge, merge_spatial_ref] = imfuse(fixed, fixed_spatial_ref, moving, moving_spatial_ref);
figure();
imshow(merge, merge_spatial_ref)

[fixed, fixed_spatial_ref] = imwarp(secA.overview.img, secA.overview.alignment.tform);
[moving, moving_spatial_ref] = imwarp(secB.overview.img, tform_rescaled_display);
[merge, merge_spatial_ref] = imfuse(fixed, fixed_spatial_ref, moving, moving_spatial_ref);
figure();
imshow(merge, merge_spatial_ref)

secB.overview.img = [];

% filename = sprintf('%s_z_aligned_Sec%d.mat', secB.wafer, secB.num);
% save(get_new_path(fullfile(filename)), 'secB', '-v7.3');

end