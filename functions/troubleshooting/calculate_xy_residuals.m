function stats = calculate_xy_residuals(sec)
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

tformsA = sec.alignments.xy.tforms;
tformsB = sec.alignments.xy.tforms;
stats = calculate_matches_stats(sec.xy_matches, tformsA, tformsB);