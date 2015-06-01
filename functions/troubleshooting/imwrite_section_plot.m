function imwrite_section_plot(sec, alignment, dir)
% Save figure of section plot
%
% Inputs:
%   sec: section struct
%   alignment: alignment struct of section
%
% imwrite_section_plot(sec, alignment)

name = sprintf('%s plot_section %s', sec.name, alignment);
fig = figure('name', name, 'visible', 'off');
plot_section(sec, alignment);
path = renderpath();
set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 5 5])
print(fig, '-r80', '-dtiff', fullfile(path.(dir), [sec.name '_' alignment '_plot.tif']));
fprintf('<strong>Writing</strong> %s for %s to renderpath\n', dir, sec.name)
