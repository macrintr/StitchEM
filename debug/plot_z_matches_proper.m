function plot_z_matches_proper(secA, secB)
% Plots the z matches between a pair of sections in both z alignments.

figure
plot_section(secA, 'z', 'r0.1')
plot_section(secB, 'z', 'g0.1')
matches = tform_z_matches(secB, secB.z_matches);
outliers = tform_z_matches(secB, secB.z_matches.outliers);
plot_matches(matches.A, matches.B)
plot_matches(outliers.A, outliers.B, 1.0, true)
axis off;

end

function matches = tform_z_matches(sec, matches)
% Put the B points into the proper space for display

B = matches.B;
for i = 1:sec.num_tiles
    tform = sec.alignments.z.tforms{i};
    pts = B.local_points(B.tile == i, :);
    tform_pts = transformPointsForward(tform, pts);
    B.global_points(B.tile == i, :) = tform_pts;
end

matches.B = B;

end