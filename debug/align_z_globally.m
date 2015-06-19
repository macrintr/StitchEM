function [secs, all_tforms] = align_z_globally(secs, start, finish)
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
if nargin < 2
    start = 2;
    finish = length(secs);
end
fixed_section = 1;

fprintf('Globally aligning sections with z matches from %d to %d.', start, finish);

[matchesA, matchesB] = compile_z_matches(secs, start, finish);
z_matches.A = matchesA;
z_matches.B = matchesB;

% Solve using least squares
[all_tforms, avg_prior_error, avg_post_error] = sp_lsq(z_matches, fixed_section);
avg_prior_error
avg_post_error

% Assign the tforms back into the z alignment slot
for s = start:finish  
    tform = all_tforms{s};
    
    % All the transforms are adjusted by the same section transformation
    rel_to = 'prev_z';
    rel_tforms = repmat({tform}, secs{s}.num_tiles, 1);
    tforms = cellfun(@(t1, t2) compose_tforms(t1, t2), secs{s}.alignments.(rel_to).tforms, rel_tforms, 'UniformOutput', false);
    
    % Calculate error
    % avg_prior_error = rownorm2(z_matches.B.global_points - z_matches.A.global_points);
    avg_post_error = rownorm2(tform.transformPointsForward(z_matches.B.global_points) - z_matches.A.global_points);
    
    % Save to structure
    alignment.tforms = tforms;
    alignment.rel_tforms = rel_tforms;
    alignment.rel_to = rel_to;
    % alignment.meta.avg_prior_error = avg_prior_error;
    alignment.meta.avg_post_error = avg_post_error;
    alignment.meta.method = mfilename;
    
    secs{s}.alignments.z = alignment;
end

size(all_tforms)