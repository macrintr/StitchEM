%% section to review
sec_num = 77;

%% review xy matches
stats = plot_xy_matches_stats(secs{sec_num});
[s, i] = sort(stats.dist, 'descend');
mov = imshow_matches(secs{sec_num}, secs{sec_num}, stats(i, :), 1);

%% remove xy matches
secs{sec_num}.xy_matches = remove_matches_by_id(secs{sec_num}.xy_matches, id_list);
stats = plot_xy_matches_stats(secs{sec_num});

%% review z matches
stats = plot_z_matches_stats(secs, sec_num);
[s, i] = sort(stats.dist, 'descend');
mov = imshow_matches(secs{sec_num-1}, secs{sec_num}, stats(i(1:20), :), 0.3);

%% remove matches
secs{sec_num}.z_matches = remove_matches_by_id(secs{sec_num}.z_matches, id_list);
stats = plot_z_matches_stats(secs, sec_num);

%% save secs
filename = sprintf('%s_clean_matches_1_10.mat', secs{1}.wafer);
save(filename, 'secs', '-v7.3');