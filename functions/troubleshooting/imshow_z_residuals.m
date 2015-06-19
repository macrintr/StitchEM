function imshow_z_residuals(secs, s)
% Display figure of z_matches stats
%
% Inputs:
%   sec: section struct
%
% imshow_z_matches_stats(sec)

name = sprintf('z residuals %s Sec%d', secs{s}.wafer, s);
figure('name', name);
plot_z_residuals(secs, s);