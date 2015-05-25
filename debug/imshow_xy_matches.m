function mov = imshow_xy_matches(sec, threshold);
% Create and display movie of xy matches (above threshold)
%
% Inputs:
%   sec: Section struct
%   threshold: minimum pixel residual of matches to look at

if nargin < 2
    threshold = 10;
end

tformsA = sec.alignments.xy.tforms;
tformsB = sec.alignments.xy.tforms;
stats = calculate_matches_stats(sec.xy_matches, tformsA, tformsB);

matches = stats(stats.dist > 10, :);
[s, idx] = sort(matches.dist, 'descend');
mov = imshow_matches(sec, sec, matches(idx, :), 0.3);

implay(mov, 1);