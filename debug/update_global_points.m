function matches = update_global_points(matches, tformsA, tformsB)
% Update the matches struct by updating transforms on global points

A = matches.A;
B = matches.B;

tilesA = unique(matches.A.tile);
tilesB = unique(matches.B.tile);

for i=tilesA
    A.global_points = transformPointsForward(tformsA{i}, A.local_points(A.tile == i, :));
end

for i=tilesB
    B.global_points = transformPointsForward(tformsB{i}, B.local_points(B.tile == i, :));
end
    
matches.A = A;
matches.B = B;