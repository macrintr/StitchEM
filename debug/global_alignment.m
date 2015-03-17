function secs = global_alignment(secs, matchesA, matchesB, start, finish)
% Globally align all tiles using least squares sparse solver
%
% Inputs:
%   secs: cell array of sec structs
%   matchesA: fixed points in the match pair
%   matchesB: moving points in the match pair
%
% Outputs:
%   secs: updated cell array, where each sec has a new z alignment

% [tforms, mean_error] = tikhonov_sparse(matchesA, matchesB);
% [tforms, mean_error] = tikhonov(matchesA, matchesB);
if nargin < 4
    start = 1;
    finish = length(secs);
else
    if start > 1
        start = start - 1;
    end
end

matches.A = matchesA;
matches.B = matchesB;
fixed_tile = 1;
[tforms, avg_prior_error, avg_post_error] = sp_lsq(matches, fixed_tile);
avg_prior_error
avg_post_error

% Assign the tforms back into the z alignment slot
tform_idx = 1;
for s = start:finish
    secs{s}.alignments.z = [];
    for i = 1:secs{s}.num_tiles
        secs{s}.alignments.z.tforms{i} = tforms{tform_idx};
        tform_idx = tform_idx + 1;
    end
    secs{s}.alignments.z.rel_to = 'initial';
    secs{s}.alignments.z.method = 'global_alignment';
end

size(tforms)
tform_idx