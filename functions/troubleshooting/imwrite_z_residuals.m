function imwrite_z_residuals(secs, s, dir)
% Save figure of xy_matches residuals
%
% Inputs:
%   sec: section struct
%
% imwrite_xy_residuals(sec, dir)

name = sprintf('%s plot_z_matches_stats', secs{s}.name);
fig = figure('name', name, 'visible', 'off');
plot_z_residuals(secs, s);
path = renderpath();
set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 20 2])
print(fig, '-r100', '-dtiff', fullfile(path.(dir), [secs{s}.name '_z_matches_residuals.tif']));
fprintf('<strong>Writing</strong> %s for %s to renderpath\n', dir, secs{s}.name);
close;
