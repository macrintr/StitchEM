function section = render_section_by_num(secs, n)
% Create aligned & stitched section from section cell series index
alignment = 'z';

sec = secs{n};
tforms = sec.alignments.(alignment).tforms;
section = render_section(sec, tforms, 'scale', 1);
