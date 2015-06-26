function matches = transform_global_matches(matches, secA, secB, alignmentA, alignmentB)
% Transform matches global_points to local_points
%
% Input
%   matches: matches struct
%   secA: fixed section struct
%   secB: moving section struct
%   alignmentA: string for fixed alignment
%   alignmentB: string for moving alignment
%
% Output
%   matches: updated matches struct with local_matches added to tables
%
% matches = transform_global_matches(matches, secA, secB, alignmentA, alignmentB)

regionsA = sec_bb(secA, alignmentA);
regionsB = sec_bb(secB, alignmentB);
tformsA = secA.alignments.(alignmentA).tforms;
tformsB = secB.alignments.(alignmentB).tforms;
tilesA = ones(height(matches.A), 1);
tilesB = ones(height(matches.B), 1);
localA = zeros(height(matches.A), 2);
localB = zeros(height(matches.B), 2);

for i = 1:height(matches.A)
    for j = 1:length(regionsA)
        if inpolygon(matches.A.global_points(i, 1), matches.A.global_points(i, 2), regionsA{j}(:, 1), regionsA{j}(:, 2))
            tilesA(i) = j;
            localA(i, :) = transformPointsInverse(tformsA{j}, matches.A.global_points(i, :));
            continue;
        end
    end
    for j = 1:length(regionsB) 
        if inpolygon(matches.B.global_points(i, 1), matches.B.global_points(i, 2), regionsB{j}(:, 1), regionsB{j}(:, 2))
            tilesB(i) = j;
            localB(i, :) = transformPointsInverse(tformsB{j}, matches.B.global_points(i, :));
            continue;
        end
    end
end

matches.A.tile = tilesA;
matches.B.tile = tilesB;
matches.A.local_points = localA;
matches.B.local_points = localB;