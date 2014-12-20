function render_secs(secs, scale, name)
% Render all the sections in a stack as one matrix
alignment = 'xy';

num_secs = length(secs);
for s = 1:num_secs
    try
        sec = secs{s};
        tforms = sec.alignments.(alignment).tforms;
        section = render_section(sec, tforms, 'scale', scale);
        filename = sprintf('%s/%s', sec.wafer, sec.name);
        if exist('name')
            filename = [filename name];
        else
            filename = [filename '_xy_rendered.tif'];
        end
        imwrite(section, fullfile(cachepath, filename));
    catch
    end
end