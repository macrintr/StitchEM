function overlap_pairs = idx_to_tile_index_pairs(idx)
% Convert insect_poly_sets idx output to a matrix of tile index pairs

overlap_pairs = [];
for i=1:size(idx,1)
    for j=1:size(idx,2)
        if ~isempty(idx{i, j})
            overlap_pairs(end+1, :) = [i j]
        end
    end
end
