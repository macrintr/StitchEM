function secs = review_xy_matches(secs, i, threshold);
% Create and display movie of xy matches (above threshold)
%
% Inputs:
%   sec: Section struct
%   threshold: minimum pixel residual of matches to look at
%
% secs = review_xy_matches(secs, i, threshold);

if nargin < 2
    threshold = 10;
end

tformsA = secs{i}.alignments.xy.tforms;
tformsB = secs{i}.alignments.xy.tforms;
stats = calculate_matches_stats(secs{i}.xy_matches, tformsA, tformsB);

matches = stats(stats.dist > threshold, :);
[s, idx] = sort(matches.dist, 'descend');
mov = imshow_matches(secs{i}, secs{i}, matches(idx, :), 0.8);

implay(mov, 1);

% Review matches
id_list = enter_array(); % Exit function by pressing '0' then 'Enter'
if length(id_list) > 0
    disp(['Removing ' num2str(length(id_list)) ' inspected matches']);
    [secs{i}.xy_matches, secs{i}.xy_matches.inspected_outliers] = remove_matches_by_id(secs{i}.xy_matches, id_list);
    
    disp('<strong>Realign xy section</strong>');
    secs{i}.alignments.xy = align_xy(secs{i});
else
    disp('No removals.\n');
end