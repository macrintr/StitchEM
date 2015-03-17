function matches = manually_add_matches(matches, imgA, imgB, tile_numA, tile_numB)
% Manually select matches to add to the provided table

[ptsB, ptsA] = cpselect(imgB, imgA, 'Wait', true);
A = table();
B = table();

A.local_points = ptsA;
A.global_points = ptsA;
A.tile = tile_numA * ones(length(ptsA), 1);

B.local_points = ptsB;
B.global_points = ptsB;
B.tile = tile_numB * ones(length(ptsA), 1);

matches.A = [matches.A; A];
matches.B = [matches.B; B];