function secB = align_rough_z(secB)
% Apply overview rough_z to the xy alignment of the tiles
%
% Inputs:
%   secB: moving section

params.overview_to_tile_resolution_ratio = 0.07;

% Then finish composing for the real scale
tform_final_overview = secB.overview.alignments.rough_z.tform;
s = params.overview_to_tile_resolution_ratio;
S = [s 0 0; 0 s 0; 0 0 1];
rel_tform_tile = affine2d(S * tform_final_overview.T * S^-1);

% Assign the rough_align_z transform to every tile
rel_tforms = cell(size(secB.alignments.xy.tforms));
rel_tforms(:) = {rel_tform_tile};

% Compose this rough overview alignment to the xy alignment by tile
tforms = cellfun(@(rough, rel) compose_tforms(rough, rel), secB.alignments.xy.tforms, rel_tforms, 'UniformOutput', false);

% Save to data structure
rough_z_alignment.tforms = tforms;
rough_z_alignment.rel_tforms = rel_tforms;
rough_z_alignment.rel_to = 'xy';
rough_z_alignment.method = 'align_rough_z';
rough_z_alignment.params = params;
secB.alignments.rough_z = rough_z_alignment;