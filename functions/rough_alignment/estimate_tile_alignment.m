function [tile_tform, tforms] = estimate_tile_alignment(tile_img, overview_img, params)
%ESTIMATE_TILE_ALIGNMENT Finds a transform that aligns a tile to its montage overview to initialize its placement.
% To get a rough alignment for a tile based on its position in its overview:
%   tile_tform = estimate_tile_alignment(tile_img, overview_img);
%
% Optionally, if the overview was already registered to another section's
% overview, simply pass in the pre-computed transformation:
%   tile_tform = estimate_tile_alignment(tile_img, overview_img, overview_tform);
%
% Optional name-value pairs and their defaults:
%   overview_scale = 0.5
%   overview_crop_ratio = 0.5
%   tile_scale = 0.05
%   show_registration = false

% Pre-process the images
tile = tile_img;
overview = overview_pre_process(overview_img, params);
% (Try to) register the tile to the overview image
try
    tform_registration = surf_register(overview, tile, params);
catch err
    fprintf('Fallback\n');
    tform_registration = fallback_registration(overview, tile, err);
end

% Check for signs of bad registration in the transform
[reg_scale, ~, reg_translation] = estimate_tform_params(tform_registration);
if reg_scale > 1.5 || reg_translation(1) > size(overview, 2) || reg_translation(2) > size(overview, 1)
    warning('First tile registration to its overview appears to be very oddly scaled or translated. Fallback!')
    tform_registration = fallback_registration(overview, tile, err);
    
    [reg_scale, ~, reg_translation] = estimate_tform_params(tform_registration);
    if reg_scale > 1.5 || reg_translation(1) > size(overview, 2) || reg_translation(2) > size(overview, 1)
        error('Second tile registration is oddly scaled or translated.');
    end
end

% Calculate the scaling transforms
tform_resolution_down = make_tform('scale', params.overview_to_tile_resolution_ratio);
tform_scale_down = make_tform('scale', params.overview_scale);
tform_scale_up = make_tform('scale', 1 / params.overview_scale);
tform_resolution_up = make_tform('scale', 1 / params.overview_to_tile_resolution_ratio);

% Calculate the translation transform
tx = size(overview_img, 2) * params.overview_cropping(1);
ty = size(overview_img, 1) * params.overview_cropping(2);
tform_translate = make_tform('translate', tx, ty);

% Compose the final tform:
% Prescale -> Register to overview -> Register overview to other overview -> Rescale
tile_tform = affine2d(tform_resolution_down.T * tform_scale_down.T * tform_registration.T * tform_scale_up.T * tform_translate.T * params.overview_tform.T * tform_resolution_up.T);

% Return the intermediate transforms as a secondary output argument
tforms.resolution_down = tform_resolution_down;
tforms.scale_down = tform_scale_down;
tforms.registration = tform_registration;
tforms.scale_up = tform_scale_up;
tforms.translate = tform_translate;
tforms.overview = params.overview_tform;
tforms.resolution_up = tform_resolution_up;

end

function tform_registration = fallback_registration(overview, tile)
% Try different parameters for registration if it failed
%disp('Could not find enough potential matches to reliably register tile to overview.')
%disp('Trying different parameters for feature detection.')

% Smooth out possible artifacts using a median filter
median_filter_radius = [6, 6];
filtered_overview = medfilt2(overview, median_filter_radius);
filtered_tile = medfilt2(tile, median_filter_radius);

% Try the registration again with fallback params
tform_registration = surf_register(filtered_overview, filtered_tile, 'fallback');
end