function imshow_section(sec, alignment)
% Display stitched section using provided alignment
%
% Inputs:
%   sec: section struct
%   alignment: alignment struct (subset of sec struct)

[section, section_R] = render_section(sec, alignment);
figure;
imshow(section, section_R);