function secB = align_section_pair_z(secA, secB)
% Rough z align and z align secB onto secA

% [secA, secB] = rough_align_z_section_pair(secA, secB);
% show_rough_z_overviews(secA, secB);

sec_nums = 1;
default_params;
z_params = params.z;

rel_alignments = {'prev_z', 'z'};

secB.alignments.prev_z = compose_alignments(secA, rel_alignments, secB, 'rough_z_xy');

% Load tile images
if ~isfield(secA.tiles, 'z') || secA.tiles.z.scale ~= z_params.scale; secA = load_tileset(secA, 'z', z_params.scale); end
if ~isfield(secB.tiles, 'z') || secB.tiles.z.scale ~= z_params.scale; secB = load_tileset(secB, 'z', z_params.scale); end
                
% Detect features in overlapping regions
secA.features.base_z = detect_features(secA, 'regions', sec_bb(secB, 'prev_z'), 'alignment', 'z', 'detection_scale', z_params.scale, z_params.SURF);
secB.features.z = detect_features(secB, 'regions', sec_bb(secA, 'z'), 'alignment', 'prev_z', 'detection_scale', z_params.scale, z_params.SURF);
                
% Match
secB.z_matches = match_z(secA, secB, 'base_z', 'z', z_params.matching);
                
if height(secB.z_matches.A) == 0
	secB.z_matches = select_z_matches(secA, secB);
	secB.z_matches = transform_z_matches_inverse({secA, secB}, 2);
	display_rendering = 1;
end

secB.alignments.z = align_z_pair_lsq(secB);

missing_tile_numbers = find(~secA.grid);
index_of_missing_tile = secB.grid(missing_tile_numbers);
if index_of_missing_tile
	fprintf('Missing tile % ', index_of_missing_tile)
	secB = propagate_z_for_missing_tiles(secA, secB);
	display_rendering = 1;
end

secA = imclear_sec(secA, 'tiles');
secA.features.base_z.tiles = [];
secB.features.z.tiles = [];
    
% Save
secB.params.z = z_params;
