function [stats, group_stats] = plot_matches_stats(matches, tformsA, tformsB)
% Plot correspondence stats dataset for distributions

% Inputs:
%   matches: struct with A & B points tables, and section names
%   tformsA: cells with tile tforms for points in mathces.A
%   tformsB: cells with tile tforms for points in mathces.B
%
% Outputs:
%   stats: dataset object containing the transformed points and the
%   computations that led to the plot
%
% There should be a tight distribution between points in the same overlap.
% If points do not closely clump in the same overlap, then there is likely
% a poor match that should be investigated.

stats = calculate_matches_stats(matches, tformsA, tformsB);

group_stats = grpstats(stats,'pair',{'mean', 'std', 'median', 'max', 'min'},'DataVars',{'dist','ang'})

pairs = unique([stats.tileA stats.tileB], 'rows');

if strcmp(matches.match_type, 'xy')
    name = sprintf('plot_matches_stats: xy_matches %s', matches.sec);
else
    name = sprintf('plot_matches_stats: z_matches %s onto %s', matches.secB, matches.secA);
end

figure('name', name);
title(name);
subplot(2, 1, 1);
scatter(stats.pair, stats.dist)
hold on
scatter(group_stats.pair, group_stats.mean_dist, '*', 'MarkerEdgeColor', [1 0 0]);
scatter(group_stats.pair, group_stats.median_dist, '*', 'MarkerEdgeColor', [0 1 0]);
% legend('correspondences', 'mean');
set(gca, 'Xtick', [1:1:size(pairs, 1)]);
labels = cellfun(@num2str, num2cell(pairs, 2), 'UniformOutput', false);
set(gca, 'XTickLabel', labels);
title('Euclidean distance between corresponding points')
xlabel('Tile pairs (A B)');
ylabel('Distance (px)');
axis normal
grid on

subplot(2, 1, 2);
scatter(stats.pair, stats.ang)
set(gca, 'Xtick', [1:1:size(pairs, 1)]);
labels = cellfun(@num2str, num2cell(pairs, 2), 'UniformOutput', false);
set(gca, 'XTickLabel', labels);
title('Direction of vector between corresponding points')
xlabel('Tile pairs (A B)');
ylabel('Angle B-to-A (rad)');
axis normal
grid on