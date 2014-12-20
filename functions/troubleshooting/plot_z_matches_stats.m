function stats = plot_z_matches_stats(secs, sec_num)
% Plot correspondence stats dataset for distributions

% Inputs:
%   sec: the section with xy matches & alignment
%
% Outputs:
%   stats: dataset object containing the transformed points and the
%   computations that led to the plot
%
% There should be a tight distribution between points in the same overlap.
% If points do not closely clump in the same overlap, then there is likely
% a poor match that should be investigated.

tformsA = secs{sec_num-1}.alignments.z.tforms;
tformsB = secs{sec_num}.alignments.z.tforms;
stats = calculate_matches_stats(secs{sec_num}.z_matches, tformsA, tformsB);

group_stats = grpstats(stats,'pair',{'mean', 'std'},'DataVars',{'dist','ang'});

pairs = unique([stats.tileA stats.tileB], 'rows');

name = sprintf('%s plot_z_matches_stats', secs{sec_num}.name);
figure('name', name);
subplot(2, 1, 1);
scatter(stats.pair, stats.dist)
hold on
scatter(group_stats.pair, group_stats.mean_dist, '*', 'MarkerEdgeColor', [1 0 0]);
legend('correspondences', 'mean');
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