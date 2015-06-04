function imwrite_error_message(sec, alignment, dir)
% Save error message to mark problem with the alignment
%
% Inputs:
%   sec: section struct
%   alignment: alignment struct of section
%   dir: the renderpath directory where it will be saved
%
% imwrite_error_message(sec, dir)

name = sprintf('%s plot_section %s', sec.name, alignment);
fig = figure('name', name, 'visible', 'off');
text(0.5, 0.5, 'error', 'HorizontalAlignment', 'center', 'FontSize', 24, 'FontWeight', 'bold', 'Color', 'red');
path = renderpath();
set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 5 5])
print(fig, '-r80', '-dtiff', fullfile(path.(dir), [sec.name '_' alignment '_plot.tif']));
close;
fprintf('<strong>Error</strong> %s for %s to renderpath\n', dir, sec.name)