z_matches = secs{2}.z_matches;
z_matches.A.section = 1 * ones(height(z_matches.A), 1);
z_matches.B.section = 2 * ones(height(z_matches.B), 1);
secs{1}.alignments.z = [];
secs{1}.alignments.z.tforms = cell(16, 1);
secs{1}.alignments.z.rel_to = 'initial';
secs{1}.alignments.z.method = 'align_tiles_z_individuals';
secs{2}.alignments.z = [];
secs{2}.alignments.z.tforms = cell(16, 1);
secs{2}.alignments.z.rel_to = 'initial';
secs{2}.alignments.z.method = 'align_tiles_z_individuals';

for i=1:16
    matches.A = z_matches.A(z_matches.A.tile == i, :);
    matches.B = z_matches.B(z_matches.B.tile == i, :);
    fixed_tile = 1;
    [rel_tforms, avg_prior_error, avg_post_error] = sp_lsq(matches, fixed_tile);
    avg_post_error
    secs{1}.alignments.z.tforms{i} = rel_tforms{1};
    secs{2}.alignments.z.tforms{i} = rel_tforms{2};
end

stats = plot_z_matches_stats(secs, 2);