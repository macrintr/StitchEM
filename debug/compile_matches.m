function [matchesA, matchesB] = compile_matches(secs, start, finish)
% Compile all xy_matches and z_matches into two tables
%
% Inputs:
%   secs: a cell array of sec structs, each with an xy_matches and
%   z_matches attribute
%
% Outputs:
%   matchesA: a table of the fixed points in the matches pair
%   matchesB: a table of the moving points in the matches pair
%
% Both matches tables will have a section attribute added to them.

if nargin < 2
    start = 1;
    finish = length(secs);
end

matchesA = table();
matchesB = table();
for i = start:finish
    Axy = secs{i}.xy_matches.A;
    Bxy = secs{i}.xy_matches.B;
    Axy.section = i * ones(height(Axy), 1);
    Bxy.section = i * ones(height(Bxy), 1);    
    
    matchesA = [matchesA; Axy];
    matchesB = [matchesB; Bxy];
    
    if i > 1
        Az = secs{i}.z_matches.A;
        Bz = secs{i}.z_matches.B;
        Az.section = (i-1) * ones(height(Az), 1);
        Bz.section = i * ones(height(Bz), 1);
        matchesA = [matchesA; Az];
        matchesB = [matchesB; Bz];
    end
end

matchesA.global_points = matchesA.local_points;
matchesB.global_points = matchesB.local_points;