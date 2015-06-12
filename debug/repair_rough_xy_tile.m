function sec = repair_rough_xy_tile(sec, tile_nums)
% Fix tile_num rough_xy by snapping to grid of other tiles
%
% Inputs:
%   sec: section struct
%   tile_nums: tile no. to repair rough_xy (can be array)

fixed_tforms = sec.alignments.rough_xy.tforms;
for i = tile_nums
    fixed_tforms{i} = [];
end
sec.alignments.rough_xy = rel_grid_alignment(sec, fixed_tforms, 'initial', 0.1);