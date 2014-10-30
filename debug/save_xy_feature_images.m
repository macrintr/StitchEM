function save_xy_feature_images(sec)
% Save section images: paired, uncropped tiles w/ matched features marked.
%
% Inputs:
%	sec: section struct
%
% Outputs:
%   no outputs
%
% Saved images legend:
%   Green circles: inlier features on the fixed tile
%   Yellow circles: inlier features on the moved tile
%   Green lines: links for corresponding inliner features between tiles
%   Red circles: outlier features on both tiles
%   Red lines: links for corresponding outlier features between tiles
%
% Thomas Macrina
% tmacrina@princeton.edu
% October 2014

pairs = unique([sec.xy_matches.A.tile sec.xy_matches.B.tile], 'rows');

for n = 1:size(pairs,1)
    A_idx = pairs(n, 1)
    B_idx = pairs(n, 2)

    tile_pair = draw_xy_matches(sec, A_idx, B_idx);
    
    % save annotated tile pair images
    filename = sprintf('%s/%s_xy_matches_%d_%d.tif', sec.name, sec.name, A_idx, B_idx);
    imwrite(tile_pair, fullfile(cachepath, filename));
end
    
    