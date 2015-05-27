function sec = remove_edge_matches(sec, tileA_num, tileB_num)
% Remove all xy matches along the edge between tileA & tileB

% Inputs
%   sec: the section containing the tile
%   tileA_num: the number of the fixed tile
%   tileB_num: the number of the moving tile

% Ouputs
%   sec: the section with a revised xy_matches attribute

badA = sec.xy_matches.A.tile == tileA_num;
badB = sec.xy_matches.B.tile == tileB_num;
badC = badA & badB;
sec.xy_matches.outliers.A = [sec.xy_matches.outliers.A; sec.xy_matches.A(badC, :)];
sec.xy_matches.outliers.B = [sec.xy_matches.outliers.B; sec.xy_matches.B(badC, :)];
sec.xy_matches.A(badC, :) = [];
sec.xy_matches.B(badC, :) = [];

sec.xy_matches.num_matches = height(sec.xy_matches.A);
