%% Load secs
load('/home/tmacrina/StitchEM/results/S2-W002_z_aligned.mat');
W002;
start = 3;
finish = 12;

%% How many matches
xy_count = [];
z_count = [];
for i=start:finish
    xy_count = [xy_count; height(secs{i}.xy_matches.A)];
    if i > start
        z_count = [z_count; height(secs{i}.z_matches.A)];
    end
end
name = 'W002 Sec3-12';
figure('name', name)
title(name)
subplot(2, 1, 1)
plot([3:12], xy_count)
title('xy matches count')
subplot(2, 1, 2)
plot([4:12], z_count)
title('z matches count')

%% Downsample
xy_count_limit = 600;
z_count_limit = 400;
xy_percentage = 1 - xy_count_limit ./ xy_count;
z_percentage = 1 - z_count_limit ./ z_count;

for i=start:finish
    matches = secs{i}.xy_matches;
    tformsA = secs{i}.alignments.xy.tforms;
    tformsB = secs{i}.alignments.xy.tforms;
    stats = calculate_matches_stats(matches, tformsA, tformsB);
    id_list = downsample_matches(stats, xy_percentage(i-start+1));
    % remove_matches_by_id will just discard matches
    secs{i}.xy_matches = remove_matches_by_id(matches, id_list);
    
    if i > start
        matches = secs{i}.z_matches;
        tformsA = secs{i}.alignments.z.tforms;
        tformsB = secs{i}.alignments.z.tforms;
        stats = calculate_matches_stats(matches, tformsA, tformsB);
        if z_percentage(i-start) > 0
            id_list = downsample_matches(stats, z_percentage(i-start));
            % remove_matches_by_id will just discard matches
            secs{i}.z_matches = remove_matches_by_id(matches, id_list);
        end
    end
end

%% Realign after downsampling to establish a baseline alignment
for i=start:finish
    secs{i}.alignments.xy = align_xy(secs{i});
    if i > start
        secs{i}.alignments.z = align_z_pair_lsq(secs{i});
    end
end

%% Remove Sec 1, 2, 13+
for i=fliplr([1 2 13:length(secs)]);
    secs(i) = [];
end

%% Save secs struct
% filename = 'S2-W002_base_matches_3_12.mat';
% save(filename, 'secs', '-v7.3');

%% Load secs
clearvars;
load('/home/tmacrina/StitchEM/S2-W002_clean_matches_3_12.mat');

%% Visually inspect xy matches
sec_idx = 1;

stats = plot_xy_matches_stats(secs{sec_idx});
m = stats(stats.dist > 10, :);
[s, i] = sort(m.dist, 'descend');

mov = imshow_matches(secs{sec_idx}, secs{sec_idx}, m(i, :), 1.0);

%% Remove xy matches
id_list = [8];
% remove_matches_by_id will just discard matches
secs{sec_idx}.xy_matches = remove_matches_by_id(secs{sec_idx}.xy_matches, id_list);

%% Save secs struct
% filename = 'S2-W002_clean_matches_3_12.mat';
% save(filename, 'secs', '-v7.3');

%% Visually inspect z matches
stats = plot_z_matches_stats(secs, sec_idx);
m = stats(stats.dist > 30, :);
[s, i] = sort(m.dist, 'descend');

mov = imshow_matches(secs{sec_idx-1}, secs{sec_idx}, m(i, :), 0.5);

%% Remove z matches
id_list = [69 175 180 137];
% remove_matches_by_id will just discard matches
secs{sec_idx}.z_matches = remove_matches_by_id(secs{sec_idx}.z_matches, id_list);

%% Add empty new_outliers struct to matches struct
for i=1:10
    new_outliers.A = secs{1}.z_matches.A;
    new_outliers.B = secs{1}.z_matches.B;
    new_outliers.A(:, :) = [];
    new_outliers.B(:, :) = [];
    if ~isfield(secs{i}.xy_matches, 'new_outliers');
        secs{i}.xy_matches.new_outliers = new_outliers;
    end
    if ~isfield(secs{i}.z_matches, 'new_outliers');
        secs{i}.z_matches.new_outliers = new_outliers;
    end
end