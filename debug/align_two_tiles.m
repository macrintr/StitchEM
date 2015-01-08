function [secA, secB] = align_two_tiles(secA, tileA_num, secB, tileB_num, params)
% Align two tiles between sections
%
% Inputs:
%   secA: first section (fixed section)
%   tileA_num: tile number in secA
%   secB: second section (moving section)
%   tileB_num: tile number in secB
%
% Outputs:
%   None
%
% Will render out the two images for inspection

z_params = params(secB.num).z;
z_params.scale = 0.3;
z_params.features.scale = 0.3;

if ~isfield(secA.tiles, 'z') || secA.tiles.z.scale ~= z_params.scale; secA = load_tileset(secA, 'z', z_params.scale); end
if ~isfield(secB.tiles, 'z') || secB.tiles.z.scale ~= z_params.scale; secB = load_tileset(secB, 'z', z_params.scale); end

secA.alignments.z = fixed_alignment(secA, 'rough_xy');

% Detect features in overlapping regions
secA.features.base_z = detect_features(secA, 'regions', sec_bb(secB, 'rough_xy'), 'alignment', 'rough_xy', 'detection_scale', z_params.scale, z_params.SURF);
secB.features.z = detect_features(secB, 'regions', sec_bb(secA, 'rough_xy'), 'alignment', 'rough_xy', 'detection_scale', z_params.scale, z_params.SURF);

for i=1:secA.num_tiles
    featsA = secA.features.base_z.tiles{i};
    if i == tileA_num
        featsA(featsA.region ~= tileB_num, :) = [];
    else
        featsA(:, :) = [];
    end
    
    featsB = secB.features.z.tiles{i};
    if i == tileB_num
        featsB(featsB.region ~= tileA_num, :) = [];
    else
        featsB(:, :) = [];
    end
    
    secA.features.base_z.tiles{i} = featsA;
    secB.features.z.tiles{i} = featsB;
end


% featsA = secA.features.base_z.tiles{tileA_num};
% featsA = featsA(featsA.region == tileB_num, :);
% secA.features.base_z.tiles = cell(16, 1);
% secA.features.base_z.tiles{tileA_num} = featsA;
% 
% featsB = secB.features.z.tiles{tileB_num};
% featsB = featsB(featsB.region == tileA_num, :);
% secB.features.z.tiles = cell(16, 1);
% secB.features.z.tiles{tileB_num} = featsB;

secB.z_matches = match_z(secA, secB, 'base_z', 'z', z_params.matching);
% filterA = secB.z_macthes.A.tile ~= tileA_num;
% filterB = secB.z_macthes.B(filterB.tile ~= tileB_num);
% secB.z_matches.A(filterB) = [];
% secB.z_matches.B(filterB) = [];

secB.alignments.z = align_z_pair_lsq(secB);
