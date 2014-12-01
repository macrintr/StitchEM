function render_secs(secs, scale)
% Render all the sections in a stack as one matrix
alignment = 'xy';

num_secs = length(secs);
for s = 1:num_secs
    sec = secs{s};
    tforms = sec.alignments.(alignment).tforms;
    section = render_section(sec, tforms, 'scale', scale);
    filename = sprintf('%s/%s_xy_rendered.tif', sec.wafer, sec.name);
    imwrite(section, fullfile(cachepath, filename));
end