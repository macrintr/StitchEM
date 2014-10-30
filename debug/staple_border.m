function [sec] = staple_border(sec, A_idx, B_idx)
% Add n "staples" to the border between tiles A & B in section sec
inliers = sec.xy_matches;
match_inliers = [inliers.A.local_points inliers.A.tile inliers.B.local_points inliers.B.tile];
tforms = sec.alignments.rough_xy.tforms;

% Table of local & global points of the features between A_idx & B_idx
mAB = match_inliers(match_inliers(:,3)==A_idx & match_inliers(:,6)==B_idx, :);

% Come up with some extra points (just add them as parallel to existing
% points)
num_points = 100; 
new_points = (1:num_points)' * (8000 / num_points);

if B_idx - A_idx <= 1
    adj_y = mAB(2, 5) - mAB(2, 2);
    
    ext_A = repmat(mAB(2, 1), num_points, 1);
    user_locals_A = [ext_A new_points];
    ext_B = repmat(mAB(2, 4), num_points, 1);
    user_locals_B = [ext_B new_points+adj_y];
else
    adj_x = mAB(1, 4) - mAB(1, 1);
    
    ext_A = repmat(mAB(1, 2), num_points, 1);
    user_locals_A = [new_points ext_A];
    ext_B = repmat(mAB(1, 5), num_points, 1);
    user_locals_B = [new_points+adj_x ext_B];    
end

user_globals_A = tforms{A_idx}.transformPointsForward(user_locals_A);
user_globals_B = tforms{B_idx}.transformPointsForward(user_locals_B);

user_table_A = table(user_locals_A, user_globals_A, ones(num_points, 1)*A_idx, 'VariableNames', {'local_points', 'global_points', 'tile'});
user_table_B = table(user_locals_B, user_globals_B, ones(num_points, 1)*B_idx, 'VariableNames', {'local_points', 'global_points', 'tile'});

sec.xy_matches.user_adjusted.A = [sec.xy_matches.user_adjusted.A; user_table_A];
sec.xy_matches.user_adjusted.B = [sec.xy_matches.user_adjusted.B; user_table_B];

end

