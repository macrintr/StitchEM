function indexed_matches = matches2dataset(matches)
% Convert two matches tables into one indexed dataset
%
% Inputs:
%   matchesA: table of matches for the fixed tiles
%   matchesB: table of matches for the moving tiles
%
% Outputs:
%   matches: dataset combining the two tables and including a common index
%
% Combining both sets of matches is useful for simpler filtering. And 
% indexing both sets is useful to track down specific feature pairs.

indexed_matches = dataset();
indexed_matches.id = [1:height(matches.A)]';
indexed_matches.localA = matches.A.local_points;
indexed_matches.localB = matches.B.local_points;
indexed_matches.globalA = matches.A.global_points;
indexed_matches.globalB = matches.B.global_points;
indexed_matches.tileA = matches.A.tile;
indexed_matches.tileB = matches.B.tile;