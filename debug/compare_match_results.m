%% Load secs
secsB = secs;
load('S2-W002_base_matches_3_12.mat');
secsA = secs;
% load('S2-W002_clean_matches_3_12.mat');
% secsB = secs;
secs = [];

%% Calculate original xy stats
count_container = [];
max_container = [];
min_container = [];
mean_container = [];
std_container = [];
for i=1:10
    matches = secsA{i}.xy_matches;
    tformsA = secsA{i}.alignments.xy.tforms;
    tformsB = secsA{i}.alignments.xy.tforms;
%     [stats_xy, group_statsA] = plot_matches_stats(matches, tformsA, tformsB);
    stats = calculate_matches_stats(matches, tformsA, tformsB);
    group_statsA = grpstats(stats,'pair',{'mean', 'std', 'median', 'max', 'min'},'DataVars',{'dist'});
     
    count_container = [count_container; group_statsA.GroupCount];
    max_container = [max_container; group_statsA.max_dist];
    min_container = [min_container; group_statsA.min_dist];
    mean_container = [mean_container; group_statsA.mean_dist];
    std_container = [std_container; group_statsA.std_dist];
end

name = 'xy match results';

%% Calculate cleaned xy stats
count_container = [];
max_container = [];
min_container = [];
mean_container = [];
std_container = [];
for i=1:10
    matches = secsB{i}.xy_matches;
    tformsA = secsA{i}.alignments.xy.tforms;
    tformsB = secsA{i}.alignments.xy.tforms;
%     [stats_xy, group_statsB] = plot_matches_stats(matches, tformsA, tformsB);
    stats = calculate_matches_stats(matches, tformsA, tformsB);
    group_statsB = grpstats(stats,'pair',{'mean', 'std', 'median', 'max', 'min'},'DataVars',{'dist'});
    
    count_container = [count_container; group_statsB.GroupCount];
    max_container = [max_container; group_statsB.max_dist];
    min_container = [min_container; group_statsB.min_dist];
    mean_container = [mean_container; group_statsB.mean_dist];
    std_container = [std_container; group_statsB.std_dist];
end

name = 'xy match results';

%% Calculate original z stats
count_container = [];
max_container = [];
min_container = [];
mean_container = [];
std_container = [];
for i=2:10
    matches = secsA{i}.z_matches;
    tformsA = secsA{i-1}.alignments.z.tforms;
    tformsB = secsA{i}.alignments.z.tforms;
%     [stats_z, group_statsA] = plot_matches_stats(matches, tformsA, tformsB);
    stats = calculate_matches_stats(matches, tformsA, tformsB);
    group_statsA = grpstats(stats,'pair',{'mean', 'std', 'median', 'max', 'min'},'DataVars',{'dist'});
    
    count_container = [count_container; group_statsA.GroupCount];
    max_container = [max_container; group_statsA.max_dist];
    min_container = [min_container; group_statsA.min_dist];
    mean_container = [mean_container; group_statsA.mean_dist];
    std_container = [std_container; group_statsA.std_dist];
end

name = 'z match results';

%% Calculate cleaned z stats
count_container = [];
max_container = [];
min_container = [];
mean_container = [];
std_container = [];
for i=2:10
    matches = secsB{i}.z_matches;
    tformsA = secsA{i-1}.alignments.z.tforms;
    tformsB = secsA{i}.alignments.z.tforms;
%     [stats_z, group_statsB] = plot_matches_stats(matches, tformsA, tformsB);
    stats = calculate_matches_stats(matches, tformsA, tformsB);
    group_statsB = grpstats(stats,'pair',{'mean', 'std', 'median', 'max', 'min'},'DataVars',{'dist'});
    
    count_container = [count_container; group_statsB.GroupCount];
    max_container = [max_container; group_statsB.max_dist];
    min_container = [min_container; group_statsB.min_dist];
    mean_container = [mean_container; group_statsB.mean_dist];
    std_container = [std_container; group_statsB.std_dist];
end

name = 'z match results';

%% Calculate stats with outliers
good_container = [];
bad_container = [];
for i=2:10
    good_matches = secsB{i}.z_matches;
    bad_matches = secsB{i}.z_matches.new_outliers;
    tformsA = secsA{i-1}.alignments.z.tforms;
    tformsB = secsA{i}.alignments.z.tforms;
    good_stats = calculate_matches_stats(good_matches, tformsA, tformsB);
    good_container = [good_container; good_stats.dist];
    if height(bad_matches.A)
        %     [stats_z, group_statsB] = plot_matches_stats(matches, tformsA, tformsB);

        bad_stats = calculate_matches_stats(bad_matches, tformsA, tformsB);
        bad_dist = bad_stats.dist(bad_stats.dist < 400, :);
        bad_container = [bad_container; bad_dist];
    end
    
%     figure;
%     edges = [0:12]*1;
%     N1 = histc(good_stats.dist, edges);
%     N2 = histc([bad_dist; 400], edges);
%     y = [N1 N2];
%     bar(edges, y, 'stacked');
    
%     group_statsB = grpstats(stats,'pair',{'mean', 'std', 'median', 'max', 'min'},'DataVars',{'dist'});
%     
%     count_container = [count_container; group_statsB.GroupCount];
%     max_container = [max_container; group_statsB.max_dist];
%     min_container = [min_container; group_statsB.min_dist];
%     mean_container = [mean_container; group_statsB.mean_dist];
%     std_container = [std_container; group_statsB.std_dist];
end

figure('name', 'W002 Sec3-12 z matches count by distance');
edges = [0:50]*4;
N1 = histc(good_container, edges);
N2 = histc(bad_container, edges);
subplot(3, 1, 1);
bar(edges, N1);
axis([-5 200 0 600]);
title('good matches');
ylabel('count');
subplot(3, 1, 2);
bar(edges, N2);
axis([-5 200 0 10]);
title('bad matches');
xlabel('distance (px)');
ylabel('count');
subplot(3, 1, 3);
B
% subplot(3, 1, 3);
% y = [N1 N2];
% bar(edges, y, 'stacked');

name = 'z match results';

%% Show plots
figure('name', name);
subplot(3, 1, 1);
hist(count_container);
title('Match count per tile pair')
subplot(3, 1, 2);
hist(max_container);
title('Max dist per tile pair')
subplot(3, 1, 3);
s = mean_container + 2 * std_container;
hist(s);
title('Mean dist + 2 std per tile pair')