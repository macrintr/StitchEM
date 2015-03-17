function plot_blockcorr_matches_global(secA, secB)
% Plots the xy matches between a pair of sections in both z alignments.

fig = figure;
plot_section(secA, 'z', 'r0.1')
plot_section(secB, 'z', 'g0.1')
matches.A = tform_z_matches(secA, secB.blockcorr_matches.A);
matches.B = tform_z_matches(secB, secB.blockcorr_matches.B);
% outliers.A = tform_z_matches(secA, secB.xy_matches.outliers.A);
% outliers.B = tform_z_matches(secB, secB.xy_matches.outliers.B);
% plot_matches(matches)
plot_matches_vectors(matches)
set(fig, 'OuterPosition', [200, 1600, 1100, 1600]);
plot_matches_contours(matches)
% plot_matches(outliers.A, outliers.B, 1.0, true)

end

function matches = tform_z_matches(sec, matches)
% Put the B points into the proper space for display

for i = 1:sec.num_tiles
    tform = sec.alignments.z.tforms{i};
    pts = matches.local_points(matches.tile == i, :);
    tform_pts = transformPointsForward(tform, pts);
    matches.global_points(matches.tile == i, :) = tform_pts;
end

end