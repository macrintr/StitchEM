function sec = repair_rough_xy_tile(sec, tile_num)
% Fix tile_num rough_xy by snapping to grid of other tiles
%
% Inputs:
%   sec: section struct
%   tile_num: tile no. to repair rough_xy

fixed_tforms = sec.alignments.rough_xy.tforms;
fixed_tforms{tile_num} = [];
sec.alignments.rough_xy = rel_grid_alignment(sec, fixed_tforms, 'initial', 0.1);