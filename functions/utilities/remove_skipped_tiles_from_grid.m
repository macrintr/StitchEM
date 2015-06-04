function new_grid = remove_skipped_tiles_from_grid(old_grid, skipped_indices)
% Remove indices that are being skipped and adjust remaining indices
%
% Inputs:
%   old_grid: mxn matrix with unique and incrementing indices
%       i.e.
%              0     0     1     0     0
%              0     0     2     3     0
%              0     0     4     5     6
%              0     0     7     8     9
%              0     0    10    11    12
%   skipped_indices: indices to remove from old_grid
%
% Outputs:
%   new_grid: mxn matrix with skipped_indices removed
%
% new_grid = remove_skipped_tiles_from_grid(old_grid, skipped_indices)

new_grid = old_grid;
for index = sort(skipped_indices)
    new_grid = new_grid - (old_grid > index);
    new_grid = new_grid .* (old_grid ~= index);
end