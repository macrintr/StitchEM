function [tform_moving_rescaled_adjusted, stats] = register_overviews(secB, secA, varargin)
%REGISTER_OVERVIEWS Registers the moving section overview montage to the fixed one.

registration_time = tic;

%% Register overviews
% Parse inputs
[params, unmatched_params] = parse_input(varargin{:});
tform_fixed = secA.overview.alignment.tform;

if params.verbosity > 0
    fprintf('== Registering overview of section %d to section %d.\n', secB.num, secA.num)
end

% Preprocess the images (resize, crop, filter)
filteredA = overview_pre_process(secA.overview.img, params);
filteredB = overview_pre_process(secB.overview.img, params);

% Register overviews
unmatched_params.SURF_MetricThreshold = 500;
unmatched_params.SURF_NumOctaves = 7;
unmatched_params.SURF_NumScaleLevels = 3;
[tform_moving, stats] = surf_register(filteredA, filteredB, unmatched_params);

% Properly rescale the transform back to our original level
s = 1/params.overview_scale;
S = [s 0 0; 0 s 0; 0 0 1];
tform_moving_rescaled = affine2d(S^-1 * tform_moving.T * S);
stats.overview_feature_scale = params.overview_scale;

% Adjust transform for initial transforms
tform_moving_rescaled_adjusted = affine2d(tform_fixed.T * tform_moving_rescaled.T);

if params.verbosity > 0
    fprintf('Done registering overviews. Mean error = %.2fpx [%.2fs]\n', stats.mean_registration_error, toc(registration_time))
end

%% Visualize results
% if params.show_registration
    % Apply the transform to fixed if needed
    if any(any(tform_fixed.T ~= eye(3)))
        [fixed, fixed_spatial_ref] = imwarp(secA.overview.img, tform_fixed);
    else
        fixed = secA.overview.img;
        fixed_spatial_ref = imref2d(size(fixed));
    end
    
    % Apply the transform to moving
    [moving, moving_spatial_ref] = imwarp(secB.overview.img, tform_moving_rescaled_adjusted);
    
    % Merge the overviews and display result
    [merge, merge_spatial_ref] = imfuse(fixed, fixed_spatial_ref, moving, moving_spatial_ref);

    filename = sprintf('%s/%s_rough_align_z_xy_%d_%d.tif', secA.wafer, secB.wafer, secA.num, secB.num);
    imwrite(imresize(merge, 0.10), fullfile(cachepath, filename));
%     figure();
%     imshow(merge, merge_spatial_ref);
    
    % convert tiles to RGB
%     A_rgb = repmat(filteredA, [1,1,3]);
%     B_rgb = repmat(filteredB, [1,1,3]);
    
    % Return the visualization
%     varargout.merge = {merge, merge_spatial_ref, fixed, fixed_spatial_ref, moving, moving_spatial_ref};
%     varargout.secA_features = draw_overview_features(A_rgb, stats.fixed_inliers, stats.fixed_matching_pts);
%     varargout.secB_features = draw_overview_features(B_rgb, stats.moving_inliers, stats.moving_matching_pts);
    
%     figure();
%     imshow(varargout.secA_features)
%     figure();
%     imshow(varargout.secB_features);
% end

end

function [params, unmatched] = parse_input(varargin)

% Create inputParser instance
p = inputParser;
p.KeepUnmatched = true;

% Pre-processing
p.addParameter('overview_scale', 0.75);
p.addParameter('overview_prescale', 1);
p.addParameter('crop_ratio', 0.9);

% Override SURF defaults
p.addParameter('SURF_MetricThreshold', 500); % MATLAB default = 1000
p.addParameter('SURF_NumOctaves', 7); % MATLAB default = 3
p.addParameter('SURF_NumScaleLevels', 3); % MATLAB default = 4

% Image filtering
p.addParameter('median_filter_radius', 6);

% Verbosity
p.addParameter('verbosity', 1);

% Visualization
p.addParameter('show_registration', false);

% Validate and parse input
p.parse(varargin{:});
params = p.Results;
unmatched = p.Unmatched;

end
