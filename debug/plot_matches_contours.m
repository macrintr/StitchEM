function plot_matches_contours(ptsA, ptsB)
% Plot displacement and orientation contours orderly matches

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

% Handle tables
if istable(ptsA)
    ptsA = ptsA.global_points;
end
if istable(ptsB)
    ptsB = ptsB.global_points;
end

d = ptsB - ptsA;
theta = atan2(-d(:, 2), d(:, 1));

% Box plot size (NEEDS TO BECOME GLOBAL)
sz = 300;
b = sz - min(ptsB(:, 1));
i = int32((ptsB(:, 1) + b) / sz);

c = sz - min(ptsB(:, 2));
j = int32((ptsB(:, 2) + c) / sz);

fig = figure;
subplot(2,1,1)
[n, norms] = rownorm2(d);
Z = accumarray([i j], norms, [], @max);
[C, h] = contourf(Z);
rotate(get(h,'children'), [0 0 1], -90)
colorbar
title('Displacement magnitude (px)')

subplot(2,1,2)
Z = accumarray([i j], theta, [], @max);
[C, h] = contourf(Z);
rotate(get(h,'children'), [0 0 1], -90)
colorbar
title('Displacement orientation (rad)')

set(fig, 'OuterPosition', [2000, 1600, 560, 1600]);