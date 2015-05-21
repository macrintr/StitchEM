function alignment = rough_align_xy(sec)
%ROUGH_ALIGN_XY Does a rough alignment on the section based on registration to its overview.
% Usage:
%   sec.alignments.rough_xy = rough_align_xy(sec)

% Base alignment
params.rel_to = 'initial';

% Overview registration
params.align_to_overview = true;
params.median_filter_radius = 6;
params.tile_scale = 0.07;
params.tile_prescale = 1;
params.overview_prescale = 1;
params.overview_scale = 0.78;
params.overview_crop_ratio = 0.5;
params.overview_cropping = [0.25 0.25 0.5 0.5];
params.median_filter_radius = 6;
params.verbosity = 3;

fprintf('== Rough aligning tiles for %s.\n', sec.name)
total_time = tic;

% Register to overview
registration_tforms = cell(sec.num_tiles, 1);
if params.align_to_overview
    
    % Tiles
    tile_set = closest_tileset(sec, params.tile_scale);
    assert(~isempty(tile_set), 'Could not find any tile sets at or above the specified scale.')
    tiles = sec.tiles.(tile_set).img;
    params.tile_prescale = sec.tiles.(tile_set).scale;
    
    % Overview
    assert(~isempty(sec.overview), 'Overview is not loaded in the section.')
    overview = sec.overview.img;
    params.overview_prescale = sec.overview.scale;
    params.overview_tform = sec.overview.alignment.tform;

    % Estimate alignments
    intermediate_tforms = cell(sec.num_tiles, 1);
    tform_warnings('off');
    
    parfor t = 1:sec.num_tiles
        registration_time = tic;
        try
            reg_params are the parameters specified by this function
            p are additional parameters needed by estimate_tile_alignments
            [registration_tforms{t}, intermediate_tforms{t}] = ...
                estimate_tile_alignment(tiles{t}, overview, params, p);
        catch
            if params.verbosity > 2; fprintf('Failed to register tile %d to overview. [%.2fs]\n', t, toc(registration_time)); end
            continue
        end
        if params.verbosity > 2; fprintf('Estimated rough alignment for section %d -> tile %d. [%.2fs]\n', tile_num, toc(registration_time)); end
    end
    tform_warnings('off');
    
    registered_tiles = find(~areempty(registration_tforms));
    if params.verbosity > 1; fprintf('Registered to overview: %s\n', vec2str(registered_tiles)); end
    
    % Metadata
    reg_meta.registered_tiles = registered_tiles;
    reg_meta.tile_set = tile_set;
    reg_meta.tile_prescale = params.tile_prescale;
    reg_meta.overview_prescale = params.overview_prescale;
    reg_meta.overview_tform = params.overview_tform;
    reg_meta.overview_rel_to_sec = sec.overview.alignment.rel_to_sec;
    reg_meta.intermediate_tforms = intermediate_tforms;
else
    if params.verbosity > 0; disp('Skipping overview registration.'); end
end

% Grid alignment
% Align unregistered tiles to grid relative to closest registered tiles
alignment = rel_grid_alignment(sec, registration_tforms, params.rel_to, params.expected_overlap);

grid_aligned = find(areempty(registration_tforms));
if params.verbosity > 1; fprintf('Grid aligned: %s\n', vec2str(grid_aligned)); end

% Additional metadata
alignment.meta.grid_aligned = grid_aligned;
alignment.meta.method = 'rough_align_xy';
if params.align_to_overview
    alignment.meta.overview_registration = reg_meta;
end

if params.verbosity > 0; fprintf('Registered <strong>%d/%d</strong> tiles to overview. [%.2fs]\n', sec.num_tiles-length(grid_aligned), sec.num_tiles, toc(total_time)); end

end