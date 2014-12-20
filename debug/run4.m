% id_list = [65 244 36 71 129 26 277 195 131];
% secs{2}.z_matches = remove_matches_by_id(secs{2}.z_matches, id_list);
start = 1;
finish = 2;
align_stack_z;
filename = sprintf('%s_jitter_fix_1_2.mat', secs{1}.wafer);
save(filename, 'secs', '-v7.3');
render_wafers;