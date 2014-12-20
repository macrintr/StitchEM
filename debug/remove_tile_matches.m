function sec = remove_tile_matches(sec, tile_num)
% Remove all xy matches associated with a given tile

% Inputs
%   sec: the section containing the tile
%   tile_num: the number of the tile whose matches need to be removed

% Ouputs
%   sec: the section with a revised xy_matches attribute

badA = sec.xy_matches.A.tile == tile_num;
sec.xy_matches.outliers.A = [sec.xy_matches.outliers.A; sec.xy_matches.A(badA, :)];
sec.xy_matches.outliers.B = [sec.xy_matches.outliers.B; sec.xy_matches.B(badA, :)];
sec.xy_matches.A(badA, :) = [];
sec.xy_matches.B(badA, :) = [];

badB = sec.xy_matches.B.tile == tile_num;
sec.xy_matches.outliers.A = [sec.xy_matches.outliers.A; sec.xy_matches.A(badB, :)];
sec.xy_matches.outliers.B = [sec.xy_matches.outliers.B; sec.xy_matches.B(badB, :)];
sec.xy_matches.A(badB, :) = [];
sec.xy_matches.B(badB, :) = [];

sec.xy_matches.num_matches = height(sec.xy_matches.A);
