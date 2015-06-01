%% Z Alignment
if ~exist('secs', 'var'); error('The ''secs'' variable does not exist. Run XY alignment or load a saved stack before doing Z alignment.'); end
disp('==== <strong>Starting z alignment</strong>.')

start = 1; finish = 3;

% Align section pairs
for s = start:finish
    fprintf('=== Aligning %s (<strong>%d/%d</strong>) in Z\n', secs{s}.name, s, length(sec_nums))
    
    % Parameters
    z_params = secs{s}.params.z;
    
    % Keep first section fixed
    if s == 1
        secs{s}.alignments.prev_z = fixed_alignment(secs{s}, 'rough_z');
        secs{s}.alignments.z = fixed_alignment(secs{s}, 'prev_z');
        secs{s}.runtime.z.timestamp = datestr(now);
        continue
    end
    
    % We're aligning section B to A
    secA = secs{s + z_params.rel_to};
    secB = secs{s};
    
    % Compose with previous Z alignment
    rel_alignments = {'rough_z', 'prev_z', 'z'};
    secB.alignments.prev_z = compose_alignments(secA, rel_alignments, secB, 'rough_z');
    
    % Keep fixed
    if strcmp(z_params.alignment_method, 'fixed')
        secB.alignments.z = fixed_alignment(secB, 'prev_z');
        secB.runtime.z.timestamp = datestr(now);
        secs{s} = secB;
        continue
    end
    
    % Match features & align
    switch z_params.matching_mode
        case 'auto'
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
            end

        case 'manual'
            secB.z_matches = select_z_matches(secA, secB);
            secB.z_matches = transform_z_matches_inverse({secA, secB}, 2);
    end

    secB.alignments.z = align_z_pair_lsq(secB);
    
    % Cover up any propagation errors caused by missing tiles
    % TO DO: Need to evaluate if this can handle back-to-back missing tiles
    % (141212 T Macrina)
    missing_tile_numbers = find(~secA.grid);
    index_of_missing_tile = secB.grid(missing_tile_numbers);
    if index_of_missing_tile
        fprintf('Missing tile % ', index_of_missing_tile)
        secB = propagate_z_for_missing_tiles(secA, secB);
    end
    
    % Save images for checking
    imwrite_section_pair(secA, secB, 'z', 'z', 'z');
    
    % Clear tile images and features to save memory
    secB.features.z.tiles = [];
    
    % Save
    secB.runtime.z.timestamp = datestr(now);
    secs{s} = secB;
    clear secA secB
    
    % Save residuals for checking
    imwrite_z_residuals(secs, s, 'z');
    
end
secs{finish} = imclear_sec(secs{finish});

disp('==== <strong>Finished z alignment</strong>.')