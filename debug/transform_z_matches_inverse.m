function matches = transform_z_matches_inverse(secs, sec_num)
% Transform z_matches global_points to local_points

matches = secs{sec_num}.z_matches;
regionsA = sec_bb(secs{sec_num-1}, 'z');
regionsB = sec_bb(secs{sec_num}, 'prev_z');
tformsA = secs{sec_num-1}.alignments.z.tforms;
tformsB = secs{sec_num}.alignments.prev_z.tforms;
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