function imwrite_secs_with_skips(secs, skip_increment)
% Save renderings of section pairs using skip_increment
%
% Inputs
%   secs: cell array of section structs
%   skip_increment: no of layers between sections
%
% Output
%   none
%
% imwrite_secs_with_skips(secs, skip_increment)

no_of_images = floor(length(secs)/skip_increment);
layers = [1:no_of_images] * skip_increment;
layer_pairs = [1 layers(1:end-1); layers];
for s = 1:no_of_images
    a = layer_pairs(1, s);
    b = layer_pairs(2, s);
    imwrite_section_pair(secs{a}, secs{b}, 'z', 'z', 'z');
end