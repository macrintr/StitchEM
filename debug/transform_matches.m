function matches = transform_matches(matches, tformsA, tformsB)
% Transform the local_points of the matches according to the input tforms
%
% Inputs:
%   matches: matches struct of a sec struct (i.e. sec.xy_matches)
%   tformsA: cell array of tforms for A table (i.e. sec.alignment.z.tforms)
%   tformsB: cell array of tforms for B table
%
% Outputs:
%   matches: updated matches struct

for i=1:length(tformsA)
    tform = tformsA{i};
    pts = transformPointsForward(tform, matches.A.local_points(matches.A.tile == i, :));
    matches.A.global_points(matches.A.tile == i, :) = pts;
end

for i=1:length(tformsB)
    tform = tformsB{i};
    pts = transformPointsForward(tform, matches.B.local_points(matches.B.tile == i, :));
    matches.B.global_points(matches.B.tile == i, :) = pts;
end