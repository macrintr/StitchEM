function plot_matches_vectors(ptsA, ptsB, scale, alt_colors)
%PLOT_MATCHES Plots the pair of matching points.
% Usage:
%   plot_matches(ptsA, ptsB)
%   plot_matches(ptsA, ptsB, scale)
%   plot_matches(ptsA, ptsB, scale, alt_colors)
%
% Notes:
%   - scale = 1.0 (default)
%   - alt_colors = false (default), if true displays matches using
%   alternative color scheme

% Handle match structs
if isstruct(ptsA)
    if isfield(ptsA, 'match_sets')
        matches = merge_match_sets(ptsA);
        ptsA = matches.A;
        ptsB = matches.B;
    elseif isfield(ptsA, 'A') && isfield(ptsA, 'B')
        ptsB = ptsA.B;
        ptsA = ptsA.A;
    end
end

if nargin < 3
    scale = 1.0;
end
if nargin < 4
    alt_colors = false;
end

if alt_colors
    pts_marker1 = 'mo';
    pts_marker2 = 'c+';
    line_marker = 'b-';
else
    pts_marker1 = 'ro';
    pts_marker2 = 'g+';
    line_marker = 'y-';
end

% Handle tables
if istable(ptsA)
    ptsA = ptsA.global_points;
end
if istable(ptsB)
    ptsB = ptsB.global_points;
end


% Scale the points
ptsA = transformPointsForward(make_tform('scale', scale), ptsA);
ptsB = transformPointsForward(make_tform('scale', scale), ptsB);

d = ptsB - ptsA;
theta = atan2(-d(:, 2), d(:, 1));

hold on
quiver(ptsA(:, 1), ptsA(:, 2), d(:, 1), d(:, 2), 1, 'color', [0 0 0]);
axis off
hold off

figure
compass(d(:, 1), -d(:, 2));

figure
rose(theta);

figure
[n, norms] = rownorm2(d);
hist(norms, 30);

figure
hist(theta, 30);

end

