function alignmentB = align_z_pair_lsq(secB, base_alignment, tform_type)
%ALIGN_Z_PAIR_LSQ Produces a Z alignment using least squares.
% Usage:
%   alignmentB = align_z_pair_lsq(secB)
%   alignmentB = align_z_pair_lsq(secB, tform_type)

if nargin < 2
    base_alignment = z_matches.alignmentB;;
end
if nargin < 3
    tform_type = 'affine';
end

z_matches = secB.z_matches;

total_time = tic;
fprintf('== Aligning %s in Z (LSQ) as <strong>%s</strong>\n', secB.name, tform_type)

if strcmp(tform_type, 'rigid')
    P = [z_matches.A.global_points ones(height(z_matches.A), 1)]';
    Q = [z_matches.B.global_points ones(height(z_matches.A), 1)]';
    [U, r, lrms] = Kabsch(P, Q);
    T = [U(1:2, 1:2) r(1:2); [0 0 1]]';
    tform = affine2d(T);
else
    % Solve using least squares
    % Ax = B -> x = A \ B
    T = [z_matches.B.global_points ones(height(z_matches.A), 1)] \ [z_matches.A.global_points ones(height(z_matches.A), 1)];
    tform = affine2d([T(:, 1:2) [0 0 1]']);
end

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
alignmentB.meta.method = mfilename;

% fprintf('Error: %f -> <strong>%fpx / match</strong> [%.2fs]\n', avg_prior_error, avg_post_error, toc(total_time))
fprintf('Error: <strong>%fpx / match</strong> [%.2fs]\n', avg_post_error, toc(total_time))
end

