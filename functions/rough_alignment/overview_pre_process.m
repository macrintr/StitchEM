function img = overview_pre_process(img, params)
% Manipulate a section overview's image for feature detection

% Resize
if params.overview_prescale ~= params.overview_scale
    img = imresize(img, (1 / params.overview_prescale) * params.overview_scale);
end

% Crop to center
if params.overview_cropping(3) < 1 || params.overview_cropping(4) < 1
    crop = params.overview_cropping;
    crop_x0 = size(img, 2) * crop(1);
    crop_y0 = size(img, 1) * crop(2);
    crop_x1 = size(img, 2) * crop(3);
    crop_y1 = size(img, 1) * crop(4);
    img = imcrop(img, [crop_x0, crop_y0, crop_x1, crop_y1]);
end

% Apply median filter
if params.median_filter_radius > 0
    img = medfilt2(img, [params.median_filter_radius params.median_filter_radius]);
end

end