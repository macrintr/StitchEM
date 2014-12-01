function stats = compare_correspondences(A, B)
% Provide Euclidean distance and orientation stats for correspondences
% Inputs:
%   A:  matches table, containing the fixed tiles
%   B:  matches table, containing the flexible tiles
% Outputs:
%   stats:  dataset of points, seam number, distance, and angle

x = B.local_points(:, 1) - A.local_points(:, 1);
y = B.local_points(:, 2) - A.local_points(:, 2);
d = sqrt(y.^2 + x.^2);
ang = atan(y./x);
pairs = unique([A.tile B.tile], 'rows');
pairs_id = 1:size(pairs, 1);
convert = [pairs_id' pairs];

all_pairs = [A.tile B.tile];
pairs_category = zeros(size(all_pairs, 1), 1);
for i=1:size(pairs, 1)
    for j=1:size(all_pairs, 1)
        if all_pairs(j, 1) == convert(i, 2) & all_pairs(j, 2) == convert(i, 3)
            pairs_category(j, 1) = convert(i, 1);
        end
    end
end

names = {'seam','x_A_local', 'y_A_local', 'x_B_local', 'y_B_local', 'x', 'y', 'd', 'ang', 'tile_A', 'tile_B'};
stats = mat2dataset([pairs_category A.local_points B.local_points x y d ang A.tile B.tile], 'VarNames', names);