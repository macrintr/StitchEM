function secs = update_sec_tforms(secs, s)
% Propagate tforms through one section, starting with rough_xy

% Transform xy matches into rough_xy, if necessary
tforms = secs{s}.alignments.rough_xy.tforms;
secs{s}.xy_matches = transform_matches(secs{s}.xy_matches, tforms, tforms);

% Update xy alignment
if isfield(secs{s}.alignments.xy, 'manual')
    rel_tforms = secs{s}.alignments.xy.rel_tforms;
    secs{s}.alignments.xy.tforms = cellfun(@(rough, rel) compose_tforms(rough, rel), tforms, rel_tforms, 'UniformOutput', false);
else
    secs{s}.alignments.xy = align_xy(secs{s});
end
%     
% % Compose updated xy with rough_z to update rough_z_xy
% num_tiles = size(secs{s}.alignments.xy.tforms, 1);
% rel_tforms_z_xy = {};
% for i=1:num_tiles
%     rel_tforms_z_xy{end+1} = secs{s}.overview.rough_align_z.tforms;
% end
% rel_tforms_z_xy = rel_tforms_z_xy';
% 
% % Compose this rough overview alignment to the xy alignment by tile
% tforms_z_xy = cellfun(@(rough, rel) compose_tforms(rough, rel), secs{s}.alignments.xy.tforms, rel_tforms_z_xy, 'UniformOutput', false);
% secs{s}.alignments.rough_z_xy.tforms = tforms_z_xy;
% secs{s}.alignments.rough_z_xy.rel_tforms = rel_tforms_z_xy;
% 
% if s == 1
%     secs{s}.alignments.prev_z = fixed_alignment(secs{s}, 'rough_z_xy');
%     secs{s}.alignments.z = fixed_alignment(secs{s}, 'rough_z_xy');
% else
%     secs{s}.alignments.prev_z = compose_alignments(secs{s-1}, {'prev_z', 'z'}, secs{s}, 'rough_z_xy');
%     secs{s}.z_matches = transform_matches(secs{s}.z_matches, secs{s-1}.alignments.z.tforms, secs{s}.alignments.prev_z.tforms);
%     secs{s}.alignments.z = align_z_pair_lsq(secs{s});
%     
%     missing_tile_numbers = find(~secs{s-1}.grid);
%     index_of_missing_tile = secs{s}.grid(missing_tile_numbers);
%     if index_of_missing_tile
%         fprintf('Missing tile % ', index_of_missing_tile)
%         secs{s} = propagate_z_for_missing_tiles(secs{s-1}, secs{s});
%     end
% end