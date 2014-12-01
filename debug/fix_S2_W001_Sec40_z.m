load('S2-W001_z_aligned_W001_Sec40.mat'); % secB

secA = secs{39};

stats = secB.overview.rough_align_z.data;
rel_tforms_z = secB.overview.rough_align_z.rel_tforms;
% rel_tforms_z = affine2d();
% tforms_z = compose_tforms(secA.overview.rough_align_z.tforms, rel_tforms_z);
tforms_z = rel_tforms_z;

% Save to data structure
z_alignment.tforms = tforms_z;
z_alignment.rel_tforms = rel_tforms_z;
z_alignment.rel_to = 'None';
% z_alignment.rel_to_sec = secA.num;
z_alignment.rel_to_sec = 'None';
z_alignment.method = 'rough_align_z';
z_alignment.data = stats;
z_alignment.data.overview_scale = secB.overview.scale;
secs{40}.overview.rough_align_z = z_alignment;
secs{39}.overview.img = [];

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
secs{40}.alignments.rough_z_xy = z_xy_alignment;