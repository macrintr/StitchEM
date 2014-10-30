% Fix section 20

sec = secs{20};
inliers = sec.xy_matches;
outliers = sec.xy_matches.outliers;
match_inliers = [inliers.A.local_points inliers.A.tile inliers.B.local_points inliers.B.tile];
match_outliers= [outliers.A.local_points outliers.A.tile outliers.B.local_points outliers.B.tile];
tforms = sec.alignments.rough_xy.tforms;

% # 1
% NEED TO DELETE FIRST & LAST ROWS IN FEATURES PAIRS HERE
% Tile 10 pts                    Tile 14
% 5.9991    7.8136    0.0100    4.2642    0.6758    0.0140
% 7.5814    7.5802    0.0100    7.4963    0.1428    0.0140
% 6.5344    7.9613    0.0100    4.2642    0.6758    0.0140

row_ids = [359, 361];
sec.xy_matches.A(row_ids, :) = [];
sec.xy_matches.B(row_ids, :) = [];

% #2
% ADD FEATURE PAIRS TO 10/14 border
A_idx = 10;
B_idx = 14;

% Table of local & global points of the features between A_idx & B_idx
m1014 = match_inliers(match_inliers(:,3)==A_idx & match_inliers(:,6)==B_idx, :);

% Come up with some extra points (just add them as parallel to existing
% points)
num_points = 100; 
new_points_x = (1:num_points)' * (8000 / num_points);

adj_x = m1014(2, 4) - m1014(2, 1); % m1014(2, n) because the first row is rubish

ext_10 = repmat(m1014(2, 2), num_points, 1);
user_locals_10 = [new_points_x ext_10];
ext_14 = repmat(m1014(2, 5), num_points, 1);
user_locals_14 = [new_points_x+adj_x ext_14];

user_globals_10 = tforms{10}.transformPointsForward(user_locals_10);
user_globals_14 = tforms{14}.transformPointsForward(user_locals_14);

user_table_10 = table(user_locals_10, user_globals_10, ones(num_points, 1)*10, 'VariableNames', {'local_points', 'global_points', 'tile'});
user_table_14 = table(user_locals_14, user_globals_14, ones(num_points, 1)*14, 'VariableNames', {'local_points', 'global_points', 'tile'});

% sec.xy_matches.user_adjusted.A = user_table_10;
% sec.xy_matches.user_adjusted.B = user_table_14;

% #3
% ADD FEATURE PAIRS TO 13/14 border
A_idx = 13;
B_idx = 14;

% Table of local & global points of the features between A_idx & B_idx
m1314 = match_inliers(match_inliers(:,3)==A_idx & match_inliers(:,6)==B_idx, :);

% Come up with some extra points (just add them as parallel to existing
% points)
new_points_y = (1:num_points)' * (8000 / num_points);

adj_y = m1314(1, 5) - m1314(1, 2);

ext_13 = repmat(m1314(1, 1), num_points, 1);
user_locals_13 = [ext_13 new_points_y];
ext_14 = repmat(m1314(1, 4), num_points, 1);
user_locals_14 = [ext_14 new_points_y + adj_y];

user_globals_13 = tforms{13}.transformPointsForward(user_locals_13);
user_globals_14 = tforms{14}.transformPointsForward(user_locals_14);

user_table_13 = table(user_locals_13, user_globals_13, ones(num_points, 1)*13, 'VariableNames', {'local_points', 'global_points', 'tile'});
user_table_14 = table(user_locals_14, user_globals_14, ones(num_points, 1)*14, 'VariableNames', {'local_points', 'global_points', 'tile'});

% sec.xy_matches.user_adjusted.A = [sec.xy_matches.user_adjusted.A; user_table_13];
% sec.xy_matches.user_adjusted.B = [sec.xy_matches.user_adjusted.B; user_table_14];

% #4
% ADD FEATURE PAIRS TO 14/15 border
A_idx = 14;
B_idx = 15;

% Table of local & global points of the features between A_idx & B_idx
m1415 = match_inliers(match_inliers(:,3)==A_idx & match_inliers(:,6)==B_idx, :);

% Come up with some extra points (just add them as parallel to existing
% points)
new_points_y = (1:num_points)' * (8000 / num_points);

adj_y = m1415(1, 5) - m1415(1, 2);

ext_14 = repmat(m1415(1, 1), num_points, 1);
user_locals_14 = [ext_14 new_points_y];
ext_15 = repmat(m1415(1, 4), num_points, 1);
user_locals_15 = [ext_15 new_points_y+adj_y];

user_globals_14 = tforms{14}.transformPointsForward(user_locals_14);
user_globals_15 = tforms{15}.transformPointsForward(user_locals_15);

user_table_14 = table(user_locals_14, user_globals_14, ones(num_points, 1)*14, 'VariableNames', {'local_points', 'global_points', 'tile'});
user_table_15 = table(user_locals_15, user_globals_15, ones(num_points, 1)*15, 'VariableNames', {'local_points', 'global_points', 'tile'});

% sec.xy_matches.user_adjusted.A = [sec.xy_matches.user_adjusted.A; user_table_14];
% sec.xy_matches.user_adjusted.B = [sec.xy_matches.user_adjusted.B; user_table_15];


% RERUN ALIGNMENT
% Rip from align_stack_xy to rerun alignment
waferpath('/mnt/data0/ashwin/07122012/S2-W001')
info = get_path_info(waferpath);
wafer = info.wafer;
sec_nums = info.sec_nums;
sec_nums(103) = []; % skip

% Load default parameters
default_params

xy_params = params(sec_nums(20)).xy;

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
% imshow(section)