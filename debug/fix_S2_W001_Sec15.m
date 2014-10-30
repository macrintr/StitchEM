% Fix section 15
s = 15;
sec = secs{s};

sec.xy_matches.user_adjusted.A = table;
sec.xy_matches.user_adjusted.B = table;

% # 1
% NEED TO DELETE FEATURES IN THESE PAIRS
% 11/12 (second feature from bottom)
row_ids = 299;
sec.xy_matches.A(row_ids, :) = [];
sec.xy_matches.B(row_ids, :) = [];

% Staple the borders on these tile pairs
sec = staple_border(sec, 3, 4);
sec = staple_border(sec, 9, 10);
sec = staple_border(sec, 7, 8);
sec = staple_border(sec, 14, 15);

% Add points to the barren border between 2&6
A_idx = 2;
B_idx = 6;

user_locals_A = [3496 7938];
user_locals_B = [3329 458];

tforms = sec.alignments.rough_xy.tforms;
user_globals_A = tforms{A_idx}.transformPointsForward(user_locals_A);
user_globals_B = tforms{B_idx}.transformPointsForward(user_locals_B);

user_table_A = table(user_locals_A, user_globals_A, A_idx, 'VariableNames', {'local_points', 'global_points', 'tile'});
user_table_B = table(user_locals_B, user_globals_B, B_idx, 'VariableNames', {'local_points', 'global_points', 'tile'});

sec.xy_matches.A = [sec.xy_matches.A; user_table_A];
sec.xy_matches.B = [sec.xy_matches.B; user_table_B];

sec = staple_border(sec, 2, 6);


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

tforms_rend = sec.alignments.xy.tforms;
section = render_section(sec, tforms_rend);
imshow(section)