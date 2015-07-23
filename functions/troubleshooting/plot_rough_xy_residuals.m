function plot_rough_xy_residuals(sec)
% Create invisible plot of xy correspondence stats dataset for distributions
%
% Inputs:
%   sec: the section with xy matches & alignment
%
% Outputs:
%   fig: figure set invisible for easy saving
%
% There should be a tight distribution between points in the same overlap.
% If points do not closely clump in the same overlap, then there is likely
% a poor match that should be investigated.
%
% fig = create_xy_matches_stats_plot(sec)

stats = calculate_rough_xy_residuals(sec);
group_stats = grpstats(stats,'pair',{'mean', 'std', 'median'},'DataVars',{'dist','ang'});

pairs = unique([stats.tileA stats.tileB], 'rows');

scatter(stats.pair, stats.dist);
hold on
scatter(group_stats.pair, group_stats.mean_dist, '*', 'MarkerEdgeColor', [1 0 0]);
scatter(group_stats.pair, group_stats.median_dist, '*', 'MarkerEdgeColor', [0 1 0]);
% legend('correspondences', 'mean', 'Location', 'best');
set(gca, 'Xtick', 1:length(pairs));
labels = cellfun(@num2str, num2cell(pairs, 2), 'UniformOutput', false);
set(gca, 'XTickLabel', labels);
title('Euclidean distance between corresponding points')
xlabel('Tile pairs (A B)');
ylabel('Distance (px)');
grid on