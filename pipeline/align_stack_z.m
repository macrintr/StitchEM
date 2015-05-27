%% Z Alignment
if ~exist('secs', 'var'); error('The ''secs'' variable does not exist. Run XY alignment or load a saved stack before doing Z alignment.'); end
disp('==== <strong>Started Z alignment</strong>.')

% Align section pairs
for s = start:finish
    status.section = s; sec_timer = tic;
    fprintf('=== Aligning %s (<strong>%d/%d</strong>) in Z\n', secs{s}.name, s, length(sec_nums))
    
    % Parameters
    z_params = secs{s}.params.z;
    display_rendering = 0;
    
    % Check for existing alignment
    if isfield(secs{s}.alignments, 'z') && ~z_params.overwrite
        error('Z:AlignedSecNotOverwritten', 'Section is already Z aligned. Set its ''overwrite'' parameter to true to overwrite alignment.')
    end
    
    % Keep first section fixed
    if s == 1
        secs{s}.alignments.z = fixed_alignment(secs{s}, 'rough_z');
        secs{s}.runtime.z.time_elapsed = toc(sec_timer);
        secs{s}.runtime.z.timestamp = datestr(now);
        continue
    end
    
    % We're aligning section B to A
    secA = secs{s + z_params.rel_to};
    secB = secs{s};
    
    % Compose with previous Z alignment
    rel_alignments = {'rough_z', 'prev_z', 'z'};
    if ~isfield(secA.alignments, 'prev_z');
        rel_alignments = 'z'; % fixed sections have no previous Z alignment
    end
    
    secB.alignments.prev_z = compose_alignments(secA, rel_alignments, secB, 'rough_z');
    
    % Keep fixed
    if strcmp(z_params.alignment_method, 'fixed')
        secB.alignments.z = fixed_alignment(secB, 'prev_z');
        secB.runtime.z.time_elapsed = toc(sec_timer);
        secB.runtime.z.timestamp = datestr(now);
        secs{s} = secB;
        continue
    end
    
    % Match features
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
                display_rendering = 1;
            end

        case 'manual'
            secB.z_matches = select_z_matches(secA, secB);
            secB.z_matches = transform_z_matches_inverse({secA, secB}, 2);
            display_rendering = 1;
    end
        
    % Check for bad matching
    if secB.z_matches.meta.avg_error > z_params.max_match_error && ~strcmp(z_params.matching_mode, 'manual')
        msg = sprintf('[%s]: Error after matching is very large. This may be because the two sections are misaligned by a large rotation/translation or due to bad matching.', secB.name);
        if z_params.ignore_error
            warning('Z:LargeMatchError', msg)
        else
            error('Z:LargeMatchError', msg)
        end
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
        display_rendering = 1;
    end
    
    % Clear tile images and features to save memory
    secA = imclear_sec(secA, 'tiles');
    secA.features.base_z.tiles = [];
    secB.features.z.tiles = [];
    
    % Save
    secB.params.z = z_params;
    secB.runtime.z.time_elapsed = toc(sec_timer);
    secB.runtime.z.timestamp = datestr(now);
    secs{s + z_params.rel_to} = secA;
    secs{s} = secB;
    clear secA secB 
    
end
