function secs = add_z_matches(secs, s)
% Add z_matches between a section and its previous neighbor

z_matches = secs{s}.z_matches;
matches = select_z_matches(secs{s-1}, secs{s}, 'z', 'xy');
matches.A = [z_matches.A; matches.A];
matches.B = [z_matches.B; matches.B];
secs{s}.z_matches = matches;
    
secs = propagate_tforms_through_secs(secs, s);
