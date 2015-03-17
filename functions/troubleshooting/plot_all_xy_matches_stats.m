function all_stats = plot_all_xy_matches_stats(secs, start, finish)
% Plot correspondence stats dataset for distributions

% Inputs:
%   secs: cell array of sections with xy matches & alignment
%
% Outputs:
%   stats: dataset object containing the transformed points and the
%   computations that led to the plot
%
% There should be a tight distribution between points in the same overlap.
% If points do not closely clump in the same overlap, then there is likely
% a poor match that should be investigated.

all_stats = dataset();

if nargin < 2
    start = 1;
    finish = length(secs);
end

for i=start:finish
    tformsA = secs{i}.alignments.z.tforms;
    tformsB = secs{i}.alignments.z.tforms;
    stats = calculate_matches_stats(secs{i}.xy_matches, tformsA, tformsB);
    sec_num = ones(length(stats), 1) * secs{i}.num;
    stats.sec_num = sec_num;
    all_stats = [all_stats; stats];
end

group_stats = grpstats(all_stats,'sec_num',{'mean', 'std'},'DataVars',{'dist','ang'});

name = sprintf('%s plot_all_xy_matches_stats', secs{start}.wafer);
figure('name', name);
subplot(2, 1, 1);
scatter(all_stats.sec_num, all_stats.dist);
hold on
scatter(group_stats.sec_num, group_stats.mean_dist, '*', 'MarkerEdgeColor', [1 0 0]);
legend('correspondences', 'mean');
set(gca, 'Xtick', [1:1:length(secs)]);
% labels = cellfun(@num2str, num2cell(pairs, 2), 'UniformOutput', false);
% set(gca, 'XTickLabel', labels);
title('Euclidean distance between corresponding points')
xlabel('Sections');
ylabel('Distance (px)');
grid on

subplot(2, 1, 2);
scatter(all_stats.sec_num, all_stats.ang)
set(gca, 'Xtick', [1:1:length(secs)]);
% labels = cellfun(@num2str, num2cell(pairs, 2), 'UniformOutput', false);
% set(gca, 'XTickLabel', labels);
title('Direction of vector between corresponding points')
xlabel('Sections');
ylabel('Angle B-to-A (rad)');
grid on