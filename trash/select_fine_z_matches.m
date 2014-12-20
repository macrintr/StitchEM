function [secB, overlaps, overlaps_with] = select_fine_z_matches(secA, secB)
% Cycle through tile overlap pairs of two sections and select matches
%
% Inputs:
%   secA: fixed section
%   secB: moving section
%
% Output:
%   secB: section with z_matches struct

% DON'T LEAVE THIS HERE!
params.scale = 0.1250;
params.min_overlap_area = 0.05;

% Load tile sets
secA = load_tileset(secA, 'z', params.scale);
secB = load_tileset(secB, 'z', params.scale);

% Define boudning boxes (we're in the space of secA with prev_z)
secB_bb = sec_bb(secB, 'prev_z');
secA_bb = sec_bb(secA, 'z');

% Intersect with specified regions
[I, idx] = intersect_poly_sets(secA_bb, secB_bb);
overlaps = arrayfun(@(t) I([idx{t, :}]), 1:secB.num_tiles, 'UniformOutput', false)';
overlaps_with = arrayfun(@(t) find(~areempty(idx(t, :))), 1:secB.num_tiles, 'UniformOutput', false)';

% Eliminate overlaps that are less than the minimum area
for t = 1:secB.num_tiles
    % Find the minimum area of the overlap for the tile
    min_area = params.min_overlap_area * polyarea(secB_bb{t}(:,1), secB_bb{t}(:,2));
    
    % Find overlap regions that meet the requirement
    valid_overlaps = cellfun(@(x) polyarea(x(:,1), x(:,2)) >= min_area, overlaps{t});
    
    % Save back to overlaps
    overlaps{t} = overlaps{t}(valid_overlaps);
    overlaps_with{t} = overlaps_with{t}(valid_overlaps);
end

if isempty(overlaps)
    % Whole tiles
    overlaps = bounding_boxes;
    overlaps_with = num2cell(1:secB.num_tiles)';
end

% % Detect features in each tile
% tile_features = cell(sec.num_tiles, 1);
% tforms = sec.alignments.(params.alignment).tforms;
% num_tile_features = zeros(sec.num_tiles, 1);
% parfor t = 1:sec.num_tiles
%     % Transform overlap regions to the local coordinate system of the tile
%     local_regions = cellfun(@(x) tforms{t}.transformPointsInverse(x), overlaps{t}, 'UniformOutput', false);
%     
%     % Detect features in tile
%     feats = detect_surf_features(tiles{t}, 'regions', local_regions, ...
%         'pre_scale', pre_scale, 'detection_scale', params.detection_scale, ...
%         params.SURF, unmatched_params);
%     
%     % Get global positions of features
%     feats.global_points = tforms{t}.transformPointsForward(feats.local_points);
%     
%     % Save to container
%     tile_features{t} = feats;
%     num_tile_features(t) = height(feats);
% end
% num_features = sum(num_tile_features);
% 
% % Save to features structure
% features.tiles = tile_features;
% features.alignment = params.alignment;
% features.num_features = num_features;
% features.num_tile_features = num_tile_features;
% features.overlaps = overlaps;
% features.overlap_with = overlaps_with;
% features.meta.section = sec.name;
% features.meta.tile_set = tile_set;
% features.meta.tile_set_scale = pre_scale;
% features.params = params;