function [matchesA, matchesB] = compile_z_matches(secs, start, finish)
% Compile all xy_matches and z_matches into two tables
%
% Inputs:
%   secs: a cell array of sec structs with z_matches attribute
%
% Outputs:
%   matchesA: a table of the fixed points in the matches pair
%   matchesB: a table of the moving points in the matches pair
%
% Both matches tables will have a section attribute added to them.
%
% [matchesA, matchesB] = compile_z_matches(secs, start, finish)

if nargin < 2
    start = 2;
    finish = length(secs);
end

matchesA = table();
matchesB = table();
for i = start:finish
    if i > 1
        Az = secs{i}.z_matches.A;
        Bz = secs{i}.z_matches.B;
        Az.section = (i-1) * ones(height(Az), 1);
        Bz.section = i * ones(height(Bz), 1);
        Az.tile = ones(height(Az), 1);
        Bz.tile = ones(height(Bz), 1);
        matchesA = [matchesA; Az];
        matchesB = [matchesB; Bz];
    end
end