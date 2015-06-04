function sec = downsample_xy_matches(sec, percent)
% Randomly remove matches from every xy seam
%
% Inputs:
%   sec: section struct
%   percent: percentage of points to remove
%
% sec = downsample_xy_matches(sec)

tforms = sec.alignments.xy.tforms;
stats = calculate_matches_stats(sec.xy_matches, tforms, tforms);
id_list = downsample_matches(stats, percent);
[sec.xy_matches, sec.xy_matches.automatic_outliers] = remove_matches_by_id(sec.xy_matches, id_list);
secs{s}.alignments.xy = align_xy(secs{s});
stats = calculate_matches_stats(sec.xy_matches, tforms, tforms);