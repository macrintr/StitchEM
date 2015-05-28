function imshow_xy_matches_stats(sec)
% Display figure of xy_matches stats
%
% Inputs:
%   sec: section struct
%
% imshow_xy_matches_stats(sec)

fig = create_xy_matches_stats_plot(sec);
set(fig,'visible','on');