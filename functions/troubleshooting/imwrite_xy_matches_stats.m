function imwrite_xy_matches_stats(sec, dir)
% Display figure of xy_matches stats
%
% Inputs:
%   sec: section struct
%
% imshow_xy_matches_stats(sec)

fig = create_xy_matches_stats_plot(sec);
print(fig, '-r80', '-dtiff', fullpath(renderpath.(dir), [sec.name '.tif']));
fprintf('<strong>Writing</strong> %s for %s to renderpath\n', dir, sec.name)