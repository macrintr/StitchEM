function [secA, secB] = align_stack_z_section_pair(secA, secB, z_params)
% Align the stitched tiles of two sections
%
% Inputs:
%   secA: fixed section
%   secB: moving section

% Align section pairs
sec_timer = tic;
fprintf('=== Aligning %s in Z\n', secB.name)

% Parameters
display_rendering = 0;

% Check for existing alignment
if isfield(secB.alignments, 'z') && ~z_params.overwrite
    error('Z:AlignedSecNotOverwritten', 'Section is already Z aligned. Set its ''overwrite'' parameter to true to overwrite alignment.')
end

% Compose with previous Z alignment
rel_alignments = {'prev_z', 'z'};
if ~isfield(secA.alignments, 'prev_z');
    rel_alignments = 'z'; % fixed sections have no previous Z alignment
end

secB.alignments.prev_z = compose_alignments(secA, rel_alignments, secB, 'rough_z_xy');

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
    case 'manual'
        secB.z_matches = select_z_matches(secA, secB);
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

% Align
switch z_params.alignment_method
    case 'lsq'
        % Least Squares
        secB.alignments.z = align_z_pair_lsq(secB);
        
    case 'cpd'
        % Coherent Point Drift
        secB.alignments.z = align_z_pair_cpd(secB);
end

% Check for bad alignment
if secB.alignments.z.meta.avg_post_error > z_params.max_aligned_error
    msg = sprintf('[%s]: Error after alignment is very large. This may be because the two sections are misaligned by a large rotation/translation or due to bad matching.', secB.name);
    if z_params.ignore_error
        warning('Z:LargeAlignmentError', msg)
    else
        error('Z:LargeAlignmentError', msg)
    end
end
    
% Save merged image
render_section_pairs(secA, secB, display_rendering);

% Clear tile images and features to save memory
secA = imclear_sec(secA, 'tiles');
secA.features.base_z.tiles = [];
secB.features.z.tiles = [];

% Save
secB.params.z = z_params;
secB.runtime.z.time_elapsed = toc(sec_timer);
secB.runtime.z.timestamp = datestr(now);
