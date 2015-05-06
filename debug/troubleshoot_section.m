function troubleshoot_section(secs, s)
% Display results of useful diagnosing functions

plot_z_matches_global(secs{s-1}, secs{s});
plot_xy_matches_global(secs{s});

stats = plot_z_matches_stats(secs, s);
stats = plot_xy_matches_stats(secs{s});
