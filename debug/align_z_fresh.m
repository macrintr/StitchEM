function alignment = align_z_fresh(secA, secB)
% Render sections, find features, and create global transform
%
% Inputs
%   secA: fixed section
%   secB: moving section
%
% Outputs
%   tform: transform to manipulate secB to secA
%
% tform = align_z_fresh(secA, secB)

scale = 0.05;
tform_type = 'rigid';

SURF_params.SURF_MetricThreshold = 500;
SURF_params.SURF_NumOctaves = 7;
SURF_params.SURF_NumScaleLevels = 3;

fixed_img = render_section(secA, 'z', 'scale', scale);
moving_img = render_section(secB, 'prev_z', 'scale', scale);

[tform_moving, stats] = surf_register(fixed_img, moving_img, SURF_params);

if strcmp(tform_type, 'rigid')
    P = [stats.moving_inliers ones(length(stats.moving_inliers), 1)]';
    Q = [stats.fixed_inliers ones(length(stats.fixed_inliers), 1)]';
    [U, r, lrms] = Kabsch(P, Q);
    T = [U(1:2, 1:2) r(1:2); [0 0 1]]';
    tform_moving = affine2d(T);
end

S = [scale 0 0; 0 scale 0; 0 0 1];
tform = affine2d(S * tform_moving.T * S^-1);

% Scale up points so we can plot them later
stats.A = transformPointsForward(make_tform('scale', 1/scale), stats.fixed_inliers);
stats.B = transformPointsForward(make_tform('scale', 1/scale), stats.moving_inliers);

% Assign the transform to every tile
rel_tforms = cell(size(secB.alignments.xy.tforms));
rel_tforms(:) = {tform};

% Compose this rough overview alignment to the xy alignment by tile
tforms = cellfun(@(rough, rel) compose_tforms(rough, rel), secB.alignments.prev_z.tforms, rel_tforms, 'UniformOutput', false);

% Save to data structure
alignment.tforms = tforms;
alignment.rel_tforms = rel_tforms;
alignment.rel_to = 'xy';
alignment.method = 'align_z_fresh';
alignment.params = SURF_params;
alignment.type = tform_type;
alignment.data = stats;