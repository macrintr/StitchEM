function plot_correspondence_stats(stats)
% Plot correspondence stats dataset for distributions

grpstats(stats,'seam',{'std'},'DataVars',{'d','ang'})

pairs = unique([stats.tile_A stats.tile_B], 'rows');

figure
subplot(2, 1, 1);
scatter(stats.seam, stats.d)
set(gca, 'Xtick', [1:1:size(pairs, 1)]);
labels = cellfun(@num2str, num2cell(pairs, 2), 'UniformOutput', false);
set(gca, 'XTickLabel', labels);
title('Euclidean distance between corresponding points')
xlabel('Tile pairs (A B)');
ylabel('Distance (px)');
grid on

subplot(2, 1, 2);
scatter(stats.seam, stats.ang)
set(gca, 'Xtick', [1:1:size(pairs, 1)]);
labels = cellfun(@num2str, num2cell(pairs, 2), 'UniformOutput', false);
set(gca, 'XTickLabel', labels);
title('Direction of vector between corresponding points')
xlabel('Tile pairs (A B)');
ylabel('Angle B-to-A (rad)');
grid on