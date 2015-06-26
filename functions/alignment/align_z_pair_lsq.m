function alignmentB = align_z_pair_lsq(secB, base_alignment, lambda)
%ALIGN_Z_PAIR_LSQ Produces a Z alignment using least squares.
% Usage:
%   alignmentB = align_z_pair_lsq(secB)
%   alignmentB = align_z_pair_lsq(secB, tform_type)

z_matches = secB.z_matches;

if nargin < 2
    base_alignment = z_matches.alignmentB;;
end
if nargin < 3
    lambda = 0.1;
end

z_matches = secB.z_matches;

total_time = tic;
fprintf('== Aligning %s in Z (LSQ) with lambda %.2f\n', secB.name, lambda)

% Set up point sets
P = [z_matches.B.global_points ones(height(z_matches.B), 1)];
Q = [z_matches.A.global_points ones(height(z_matches.A), 1)];

% rigid alignment
[R, t, lrms] = Kabsch(P', Q');
rigid = [R(1:2, 1:2) t(1:2); [0 0 1]]';

% Solve using least squares
% AP = Q -> A = P \ Q
A = P \ Q;
affine = [A(:, 1:2) [0 0 1]'];

T = (1-lambda) * affine + lambda * rigid;
tform = affine2d(T);

% All the transforms are adjusted by the same section transformation
rel_to = base_alignment;
rel_tforms = repmat({tform}, secB.num_tiles, 1);
tforms = cellfun(@(t1, t2) compose_tforms(t1, t2), secB.alignments.(rel_to).tforms, rel_tforms, 'UniformOutput', false);

% Calculate error
% avg_prior_error = rownorm2(z_matches.B.global_points - z_matches.A.global_points);
avg_post_error = rownorm2(tform.transformPointsForward(z_matches.B.global_points) - z_matches.A.global_points);

% Save to structure
alignmentB.tforms = tforms;
alignmentB.rel_tforms = rel_tforms;
alignmentB.rel_to = rel_to;
% alignmentB.meta.avg_prior_error = avg_prior_error;
alignmentB.meta.avg_post_error = avg_post_error;
alignmentB.meta.rigid = rigid;
alignmentB.meta.affine = affine;
alignmentB.meta.lambda = lambda;
alignmentB.meta.method = mfilename;

% fprintf('Error: %f -> <strong>%fpx / match</strong> [%.2fs]\n', avg_prior_error, avg_post_error, toc(total_time))
fprintf('Error: <strong>%fpx / match</strong> [%.2fs]\n', avg_post_error, toc(total_time))
end

