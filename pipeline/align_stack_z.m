%% Z Alignment
if ~exist('secs', 'var'); error('The ''secs'' variable does not exist. Run XY alignment or load a saved stack before doing Z alignment.'); end
disp('==== <strong>Starting z alignment</strong>.')

start = 122; finish = length(secs);

% Align section pairs
for s = start:finish
    fprintf('=== Aligning %s (<strong>%d/%d</strong>) in Z\n', secs{s}.name, s, length(sec_nums))
    
    % Parameters
    z_params = secs{s}.params.z;
    k = z_params.rel_to;
    
    % Keep first section fixed
    if s == 1
        secs{s}.alignments.prev_z = fixed_alignment(secs{s}, 'rough_z');
        secs{s}.alignments.z = fixed_alignment(secs{s}, 'prev_z');
        secs{s}.runtime.z.timestamp = datestr(now);
        continue
    end
    
    % Compose with previous Z alignment
    rel_alignments = {'rough_z', 'prev_z', 'z'};
    secs{s}.alignments.prev_z = compose_alignments(secs{s + k}, rel_alignments, secs{s}, 'rough_z');
    
    % Keep fixed
    if strcmp(z_params.alignment_method, 'fixed')
        secs{s}.alignments.z = fixed_alignment(secs{s}, 'prev_z');
        secs{s}.runtime.z.timestamp = datestr(now);
        secs{s} = secs{s};
        continue
    end
    
    % Match features & align
    switch z_params.matching_mode
        case 'auto'
            % Load tile images
            if ~isfield(secs{s + k}.tiles, 'z') || secs{s + k}.tiles.z.scale ~= z_params.scale; secs{s + k} = load_tileset(secs{s + k}, 'z', z_params.scale); end
            if ~isfield(secs{s}.tiles, 'z') || secs{s}.tiles.z.scale ~= z_params.scale; secs{s} = load_tileset(secs{s}, 'z', z_params.scale); end

            % Detect features in overlapping regions
            secs{s + k}.features.base_z = detect_features(secs{s + k}, 'regions', sec_bb(secs{s}, 'prev_z'), 'alignment', 'z', 'detection_scale', z_params.scale, z_params.SURF);
            secs{s}.features.z = detect_features(secs{s}, 'regions', sec_bb(secs{s + k}, 'z'), 'alignment', 'prev_z', 'detection_scale', z_params.scale, z_params.SURF);

            % Match
            secs{s}.z_matches = match_z(secs{s + k}, secs{s}, 'base_z', 'z', z_params.matching);

            if height(secs{s}.z_matches.A) == 0
                secs{s}.z_matches = select_z_matches(secs{s + k}, secs{s});
                secs{s}.z_matches = transform_z_matches_inverse({secs{s + k}, secs{s}}, 2);
            end
            
            % Clear tile features to save memory
            secs{s + k}.features.base_z = [];

        case 'manual'
            secs{s}.z_matches = select_z_matches(secs{s + k}, secs{s});
            secs{s}.z_matches = transform_z_matches_inverse({secs{s + k}, secs{s}}, 2);
    end

    secs{s}.alignments.z = align_z_pair_lsq(secs{s});    
    secs = clean_z_matches(secs, s, 200);
    secs = clean_z_matches(secs, s, 120);
    
    % Cover up any propagation errors caused by missing tiles
    % TO DO: Need to evaluate if this can handle back-to-back missing tiles
    % (141212 T Macrina)
    missing_tile_numbers = find(~secs{s + k}.grid);
    index_of_missing_tile = secs{s}.grid(missing_tile_numbers);
    if index_of_missing_tile
        fprintf('Missing tile % ', index_of_missing_tile)
        secs{s} = propagate_z_for_missing_tiles(secs{s + k}, secs{s});
    end
    
    % Save images for checking
    imwrite_section_pair(secs{s + k}, secs{s}, 'z', 'z', 'z');
    
    % Clear tile images and features to save memory
    secs{s}.features.z.tiles = [];
    secs{s + k} = imclear_sec(secs{s + k});
    
    % Save
    secs{s}.runtime.z.timestamp = datestr(now);
    
    % Save residuals for checking
    imwrite_z_residuals(secs, s, 'z');
    
end
secs{finish} = imclear_sec(secs{finish});
disp('==== <strong>Finished z alignment</strong>.')

filename = 'wafers_zfish/150602_W004.mat';
save(filename, 'secs', '-v7.3');
disp('==== <strong>Saved secs</strong>.')