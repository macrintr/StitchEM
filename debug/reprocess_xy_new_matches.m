% Realign the section
sec.alignments.xy = align_xy(sec);
plot_rough_xy(sec), plot_matches(sec.xy_matches);

% Save the section
filename = sprintf('%s_Sec%d_xy_aligned.mat', sec.wafer, sec.num);
save(filename, 'sec', '-v7.3')

% Save the render
% section = render_section(sec, 'xy', 'scale', 0.02);
% filename = sprintf('%s/%s_xy_rendered.tif', sec.wafer, sec.name);
% imwrite(section, fullfile(cachepath, filename));
% imshow(section)

% Save the section back into the wafer object
secs{sec.num} = sec;
filename = sprintf('%s_xy_aligned.mat', sec.wafer);
save(filename, 'secs', 'error_log', '-v7.3');
