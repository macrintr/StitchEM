function img = overview_pre_process(im, params)
% Manipulate a section overview's image for feature detection

img = im;
% Resize
if params.overview_prescale ~= params.overview_scale
    img = imresize(img, (1 / params.overview_prescale) * params.overview_scale);
end

% Crop to center
% crop_start = (1 - params.crop_ratio) / 2;
% crop_end = params.crop_ratio;
% img = imcrop(img, [size(im, 2) * crop_start, size(img, 1) * crop_start, size(img, 2) * crop_end, size(img, 1) * crop_end]);

% Apply median filter
if params.median_filter_radius > 0
    img = medfilt2(img, [params.median_filter_radius params.median_filter_radius]);
end

end