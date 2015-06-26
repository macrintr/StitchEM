function stats = calculate_matches_stats(matches, tformsA, tformsB)
% Provide Euclidean distance and orientation stats for two matches tables
%
% Inputs:
%   A:  matches table, containing the fixed tiles
%   B:  matches table, containing the flexible tiles
%   (matches table contains local_points, global_points, and tiles - see
%   xy_matches attribute of any sec struct)

% Outputs:
%   stats:  dataset of points, seam number, distance, and angle

matches = matches2dataset(matches);
stats = dataset();

pair_set = unique([matches.tileA matches.tileB], 'rows');

% Cycle through all the seams
for i=1:size(pair_set, 1)
    
    % Determine the two tiles involved in this seam
    tileA = pair_set(i, 1);
    tileB = pair_set(i, 2);
    
    % Determine the two transforms for these two tiles
    tformA = tformsA{tileA};
    tformB = tformsB{tileB};
    
    % Pull out the match pairs only at the seam we're interested in
    pts = matches(matches.tileA == tileA & matches.tileB == tileB, :);
    % Adjust those points based on the transform of its tile
    pts.tformsA = transformPointsForward(tformA, pts.localA);
    pts.tformsB = transformPointsForward(tformB, pts.localB);

    % Provide a pair category so it can be noted on a chart easily
    pts.pair = ones(length(pts), 1) * i;
    
    stats = [stats; pts];
    
end

% Calculate displacements in both dimensions
stats.dx = stats.tformsB(:, 1) - stats.tformsA(:, 1);
stats.dy = stats.tformsB(:, 2) - stats.tformsA(:, 2);
% Calculate the 2-norm distance & orientation
stats.dist = sqrt(stats.dy.^2 + stats.dx.^2);
stats.ang = atan2(stats.dy, stats.dx);

fprintf('No of matches: <strong>%d</strong>\n', length(stats))