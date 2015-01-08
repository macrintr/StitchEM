function secs = global_alignment(secs, matchesA, matchesB)
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
matches.A = matchesA;
matches.B = matchesB;
fixed_tile = 1;
[rel_tforms, avg_prior_error, avg_post_error] = sp_lsq(matches, fixed_tile);
avg_prior_error
avg_post_error
tforms = reshape(rel_tforms, [16 2]);

% Apply the calculated transforms to the rough tforms
for s = 1:size(tforms, 2)
    secs{s}.alignments.z = [];
    secs{s}.alignments.z.tforms = tforms(:, s);
    secs{s}.alignments.z.rel_to = 'initial';
    secs{s}.alignments.z.method = 'global_alignment';
end