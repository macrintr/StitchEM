stats = plot_xy_matches_stats(secs{1});
% m = stats(stats.tileA == 1 & stats.tileB == 1, :);
[s, i] = sort(stats.dist, 'descend');
% id_list = m.id(i);
mov = imshow_matches(secs{1}, secs{1}, stats(i, :), 1);

stats = plot_xy_matches_stats(secs{2});
[s, i] = sort(stats.dist, 'descend');
mov = imshow_matches(secs{2}, secs{2}, stats(i, :), 1);

stats = plot_z_matches_stats(secs, 2);
[s, i] = sort(stats.dist, 'descend');
mov = imshow_matches(secs{1}, secs{2}, stats(i, :), 0.2);