function imwrite_xy_residuals(sec, dir)
% Save figure of xy_matches residuals
%
% Inputs:
%   sec: section struct
%
% imwrite_xy_residuals(sec, dir)

name = sprintf('%s plot_xy_matches_stats', sec.name);
fig = figure('name', name, 'visible', 'off');
plot_xy_residuals(sec);
path = renderpath();
set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 10 2])
print(fig, '-r100', '-dtiff', fullfile(path.(dir), [sec.name '_xy_matches_stats.tif']));
fprintf('<strong>Writing</strong> %s for %s to renderpath\n', dir, sec.name);
close;