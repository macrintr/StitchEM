stats = plot_z_matches_stats(secs, 2);
m = stats(stats.tileA == 1 & stats.tileB == 1, :);
[s, i] = sort(m.dist, 'descend');
id_list = m.id(i);

mov = imshow_matches(secs{1}, secs{2}, m(i, :), 'z');