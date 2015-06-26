function secs = review_z_matches(secs, i, threshold);
% Create and display movie of xy matches (above threshold)
%
% Inputs:
%   sec: Section struct
%   threshold: minimum pixel residual of matches to look at

if nargin < 2
    threshold = 120;
end

base_alignment = 'xy';

tformsA = secs{i-1}.alignments.z.tforms;
tformsB = secs{i}.alignments.z.tforms;
stats = calculate_matches_stats(secs{i}.z_matches, tformsA, tformsB);

matches = stats(stats.dist > threshold, :);
[s, idx] = sort(matches.dist, 'descend');
mov = imshow_matches(secs{i-1}, secs{i}, matches(idx, :), 0.3);

implay(mov, 1);

% Review matches
id_list = enter_array(); % Exit function by pressing '0' then 'Enter'
if length(id_list) > 0
    disp(['Removing ' num2str(length(id_list)) ' inspected matches']);
    [secs{i}.z_matches, secs{i}.z_matches.inspected_outliers] = remove_matches_by_id(secs{i}.z_matches, id_list);
    
    disp('<strong>Realign z section</strong>');
    secs{i}.alignments.z = align_z_pair_lsq(secs{i}, base_alignment);
else
    disp('No removals.\n');
end