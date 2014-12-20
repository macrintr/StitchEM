clearvars;
load('S2-W001_jitter_fix.mat')
for i=2:50
    sec = secs{i};
    matchesA = sec.z_matches.A;
    matchesB = sec.z_matches.B;
    tformsA = secs{i-1}.alignments.z.tforms;
    tformsB = sec.alignments.z.tforms;
    stats = calculate_matches_stats(matchesA, matchesB, tformsA, tformsB);
    
    med = median(stats.dist);
    sd = std(stats.dist);
    
    id_list = stats.id(stats.dist > med+3*sd, :);
    sec.z_matches = remove_matches_by_id(sec.z_matches, id_list);
    
    secs{i} = sec;
end

filename = sprintf('%s_jitter_fix_z.mat', secs{1}.wafer);
save(filename, 'secs', '-v7.3');

stats = plot_all_z_matches_stats(secs, 2, 50);

start = 1;
finish = 50;
align_stack_z;

filename = sprintf('%s_jitter_fix_z.mat', secs{1}.wafer);
save(filename, 'secs', '-v7.3');