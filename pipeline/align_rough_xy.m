function alignment = align_rough_xy(sec)
%ROUGH_ALIGN_XY Does a rough alignment on the section based on registration to its overview.
% Usage:
%   sec.alignments.rough_xy = rough_align_xy(sec)

params = sec.params.rough_xy;

fprintf('== Rough aligning tiles for %s.\n', sec.name)
total_time = tic;

% Register to overview
registration_tforms = cell(sec.num_tiles, 1);
if params.align_to_overview
    
    % Tiles
    % Load rough tileset
    if ~isfield(sec.tiles, 'rough'); sec = load_tileset(sec, 'rough', params.overview_to_tile_resolution_ratio * params.overview_scale); end
    tile_set = 'rough';
    tiles = sec.tiles.rough.img;
    
    % Overview
    assert(~isempty(sec.overview), 'Overview is not loaded in the section.')
    overview = sec.overview.img;    
    params.overview_tform = sec.overview.alignments.initial.tform;

    % Estimate alignments
    intermediate_tforms = cell(sec.num_tiles, 1);
    tform_warnings('off');
    
    tile = tiles{1};
    
    parfor t = 1:sec.num_tiles
        registration_time = tic;
        try            
            % reg_params are the parameters specified by this function
            % p are additional parameters needed by estimate_tile_alignments
            [registration_tforms{t}, intermediate_tforms{t}] = ...
                estimate_tile_alignment(tiles{t}, overview, params);
        catch
            fprintf('Failed to register tile %d to overview. [%.2fs]\n', t, toc(registration_time));
            continue
        end
    end
    tform_warnings('off');
    
    registered_tiles = find(~areempty(registration_tforms));
    fprintf('Registered to overview: %s\n', vec2str(registered_tiles));
    
    % Metadata
    reg_meta.registered_tiles = registered_tiles;
    reg_meta.tile_set = tile_set;
    reg_meta.tile_prescale = params.tile_prescale;
    reg_meta.overview_prescale = params.overview_prescale;
    reg_meta.overview_tform = params.overview_tform;
    reg_meta.overview_rel_to_sec = sec.overview.alignments.initial.rel_to_sec;
    reg_meta.intermediate_tforms = intermediate_tforms;
else
    disp('Skipping overview registration.');
end

% Grid alignment
% Align unregistered tiles to grid relative to closest registered tiles
alignment = rel_grid_alignment(sec, registration_tforms, params.rel_to, params.expected_overlap);

grid_aligned = find(areempty(registration_tforms));
fprintf('Grid aligned: %s\n', vec2str(grid_aligned));

% Additional metadata
alignment.meta.grid_aligned = grid_aligned;
alignment.meta.method = 'rough_align_xy';
if params.align_to_overview
    alignment.meta.overview_registration = reg_meta;
end

fprintf('Registered <strong>%d/%d</strong> tiles to overview. [%.2fs]\n', sec.num_tiles-length(grid_aligned), sec.num_tiles, toc(total_time));

end