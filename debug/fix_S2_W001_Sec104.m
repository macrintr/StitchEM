% Fix section 104
s = 104;
sec = secs{s};

sec.xy_matches.user_adjusted.A = table;
sec.xy_matches.user_adjusted.B = table;

% # 1
% NEED TO DELETE FEATURES IN THESE PAIRS
% 2/6
% T6: 8th & 9th from right
% 4.5554
% 13/14
% T14: 1st & 2nd from bottom
% 7.6929

row_ids = [63, 72, 417, 423];
sec.xy_matches.A(row_ids, :) = [];
sec.xy_matches.B(row_ids, :) = [];

% Staple the borders on these tile pairs
% sec = staple_border(sec, 3, 4);
% sec = staple_border(sec, 9, 10);
% sec = staple_border(sec, 7, 8);
% sec = staple_border(sec, 14, 15);


% RERUN ALIGNMENT
% Rip from align_stack_xy to rerun alignment
waferpath('/mnt/data0/ashwin/07122012/S2-W001')
info = get_path_info(waferpath);
wafer = info.wafer;
sec_nums = info.sec_nums;

% Load default parameters
default_params

xy_params = params(sec_nums(s)).xy;

% Align XY
sec.alignments.xy = align_xy(sec, xy_params.align);

% Flag bad alignment
if sec.alignments.xy.meta.avg_post_error > xy_params.max_aligned_error
    disp('<strong>STOP</strong> XY overall alignment error beyond threshold');
    sec.error_log{end+1} = sprintf('%s: sec.alignments.xy.meta.avg_post_error > xy_params.max_aligned_error', sec.name);
    % msg = sprintf('[%s]: Error after alignment is very large. This may be due to bad matching.', sec.name);
    % id = 'XY:LargeAlignmentError';
    % if xy_params.ignore_error; warning(id, msg); else error(id, msg); end
end

alignment = 'xy';
tforms = sec.alignments.(alignment).tforms;
section = render_section(sec, tforms, 'scale', 0.08);
filename = sprintf('%s/%s_xy_rendered.tif', sec.wafer, sec.name);
imwrite(section, fullfile(cachepath, filename));

secs{104} = sec;