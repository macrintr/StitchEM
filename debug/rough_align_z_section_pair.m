function [secA, secB] = rough_align_z_section_pair(secA, secB)
% Align the overviews of two sections & create tile specific transforms
%
% Inputs:
%   secA: fixed section
%   secB: moving section

overview_to_tile_ratio = 0.07;

% Load overview for the sections
secB = load_overview(secB, secB.overview.scale);
if isempty(secA.overview.img)
    secA = load_overview(secA, secA.overview.scale);
end

% Set the relative transform
rel_tforms_z = affine2d();
% Is the relative transform already set? (i.e. from manual selection)
[tform_moving, stats] = register_overviews(secB, secA);
z_alignment.rel_to = 'None';
z_alignment.rel_to_sec = secA.num;
z_alignment.method = 'rough_align_z';
z_alignment.data = stats;
z_alignment.data.overview_scale = secB.overview.scale;
    
% Rescale for the overview scale factor & tile-to-overview ratio
scaling_factor = 1/(secB.overview.scale * overview_to_tile_ratio);
scaling_matrix = [scaling_factor 0 0; 0 scaling_factor 0; 0 0 1];
rel_tforms_z = affine2d(scaling_matrix^-1 * tform_moving.T * scaling_matrix);

% Propagate the previous section's rough_z alignment
tforms_z = compose_tforms(secA.overview.rough_align_z.tforms, rel_tforms_z);

% Save to data structure
z_alignment.tforms = tforms_z;
z_alignment.rel_tforms = rel_tforms_z;
secB.overview.rough_align_z = z_alignment;
secA.overview.img = [];

% Assign the rough_align_z transform to every tile
num_tiles = size(secB.alignments.xy.tforms, 1);
rel_tforms_z_xy = {};
for i=1:num_tiles
    rel_tforms_z_xy{end+1} = tforms_z;
end
rel_tforms_z_xy = rel_tforms_z_xy';

% Compose this rough overview alignment to the xy alignment by tile
tforms_z_xy = cellfun(@(rough, rel) compose_tforms(rough, rel), secB.alignments.xy.tforms, rel_tforms_z_xy, 'UniformOutput', false);

% Save to data structure
z_xy_alignment.tforms = tforms_z_xy;
z_xy_alignment.rel_tforms = rel_tforms_z_xy;
z_xy_alignment.rel_to = 'overview.rough_align_z';
z_xy_alignment.method = 'rough_align_z';
secB.alignments.rough_z_xy = z_xy_alignment;




