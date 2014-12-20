m = stats(stats.tileA == 2 & stats.tileB == 6, :);
[s, i] = sortrows(m, 'localA', 'descend');

mov = imshow_matches(secs{2}, secs{2}, m(i, :), 'xy');

tile_pair = draw_xy_matches(secs{2}, 2, 6);
imshow(tile_pair)