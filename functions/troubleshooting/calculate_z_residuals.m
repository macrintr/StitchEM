function stats = calculate_z_residuals(secs, sec_num)
% Calculate xy_match stats
%
% Inputs:
%   sec: the section with xy matches & alignment
%
% Outputs:
%   stats: table of transformed matches and their displacements
%
% There should be a tight distribution between points in the same overlap.
% If points do not closely clump in the same overlap, then there is likely
% a poor match that should be investigated.
%
% stats = calculate_xy_matches_stats(sec)

tformsA = secs{sec_num-1}.alignments.z.tforms;
tformsB = secs{sec_num}.alignments.z.tforms;
stats = calculate_matches_stats(secs{sec_num}.z_matches, tformsA, tformsB);