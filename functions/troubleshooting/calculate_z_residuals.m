function stats = calculate_z_residuals(secs, s)
% Calculate xy_match stats
%
% Inputs:
%   sec: the section with xy matches & alignment
%   s: section number
%
% Outputs:
%   stats: table of transformed matches and their displacements
%
% There should be a tight distribution between points in the same overlap.
% If points do not closely clump in the same overlap, then there is likely
% a poor match that should be investigated.
%
% stats = calculate_xy_matches_stats(sec)

k = secs{s}.params.z.rel_to;
tformsA = secs{s+k}.alignments.z.tforms;
tformsB = secs{s}.alignments.z.tforms;
stats = calculate_matches_stats(secs{s}.z_matches, tformsA, tformsB);