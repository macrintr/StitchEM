function secs = propagate_tforms(secs, sec_num)
% Propagate a tform through an entire stack, starting with the xy tform

% Transform xy matches into rough_xy, if necessary
tforms = secs{sec_num}.alignments.rough_xy.tforms;
secs{sec_num}.xy_matches = transform_matches(secs{sec_num}.xy_matches, tforms, tforms);

% Compose updated xy with rough_z to update rough_z_xy
num_tiles = size(secs{sec_num}.alignments.xy.tforms, 1);
rel_tforms_z_xy = {};
for i=1:num_tiles
    rel_tforms_z_xy{end+1} = secs{sec_num}.overview.rough_align_z.tforms;
end
rel_tforms_z_xy = rel_tforms_z_xy';

% Compose this rough overview alignment to the xy alignment by tile
tforms_z_xy = cellfun(@(rough, rel) compose_tforms(rough, rel), secs{sec_num}.alignments.xy.tforms, rel_tforms_z_xy, 'UniformOutput', false);

% Save to data structure
z_xy_alignment.tforms = tforms_z_xy;
z_xy_alignment.rel_tforms = rel_tforms_z_xy;
z_xy_alignment.rel_to = 'overview.rough_align_z';
z_xy_alignment.method = 'rough_align_z';
secs{sec_num}.alignments.rough_z_xy = z_xy_alignment;

% Propagate through to the end of the secs
for s = sec_num:length(secs)
    if s == 0
        secs{s}.alignments.prev_z = fixed_alignment(secs{s}, 'rough_z_xy');
        secs{s}.alignments.z = fixed_alignment(secs{s}, 'rough_z_xy');
    else
        secs{s}.alignments.prev_z = compose_alignments(secs{s-1}, {'prev_z', 'z'}, secs{s}, 'rough_z_xy');
        secs{s}.z_matches = transform_matches(secs{s}.z_matches, secs{s-1}.alignments.z.tforms, secs{s}.alignments.prev_z.tforms);
        secs{s}.alignments.z = align_z_pair_lsq(secs{s});
        
        missing_tile_numbers = find(~secs{s-1}.grid);
        index_of_missing_tile = secs{s}.grid(missing_tile_numbers);
        if index_of_missing_tile
            fprintf('Missing tile % ', index_of_missing_tile)
            secs{s} = propagate_z_for_missing_tiles(secs{s-1}, secs{s});
        end
    end
end