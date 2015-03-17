% Align section pairs
for s = start:finish
       
    % Keep first section fixed
    if s == 1
        secs{s}.alignments.z = fixed_alignment(secs{s}, 'rough_z_xy');
        continue
    end

    % Transform matches of current sec (xy & z) to frame of previous sec
    tformsA = secs{s-1}.alignments.z.tforms;
    matchesA = secs{s}.z_matches.A;
    matchesB = secs{s}.z_matches.B;
    
    for i=1:length(tformsA)
        tform = tformsA{i};
        ptsA = transformPointsForward(tform, matchesA.local_points(matchesA.tile == i, :));
        matchesA.global_points(matchesA.tile == i, :) = ptsA;
        ptsB = transformPointsForward(tform, matchesB.local_points(matchesB.tile == i, :));
        matchesB.global_points(matchesB.tile == i, :) = ptsB;        
    end
    
    secs{s}.z_matches.A = matchesA;
    secs{s}.z_matches.B = matchesB;
    
    % Align current sec to previous (fixed) sec
    secs{s}.alignments.z = align_z_pair_lsq(secs{s});
end