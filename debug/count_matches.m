xy_matches = [];
z_matches = [];
for i=[1:51 53:length(secs)] % Sec52 doesn't have local_points for some reason
    % count xy matches
    alignment_type = 'xy';
    matches_type = [alignment_type '_matches'];
    j = i;
    db_threshold = 15;
    pb_threshold = 3;

    matches = secs{i}.(matches_type);
    tformsA = secs{j}.alignments.(alignment_type).tforms;
    tformsB = secs{i}.alignments.(alignment_type).tforms;
    [stats, definitely_bad, possibly_bad] = segment_bad_matches(matches, tformsA, tformsB, db_threshold, pb_threshold);
    xy_matches = [xy_matches; length(stats) length(definitely_bad) length(possibly_bad)];
    
    % count z matches
    alignment_type = 'z';
    matches_type = [alignment_type '_matches'];
    j = i-1;
    db_threshold = 120;
    pb_threshold = 30;
    
    matches = secs{i}.(matches_type);
    tformsA = secs{j}.alignments.(alignment_type).tforms;
    tformsB = secs{i}.alignments.(alignment_type).tforms;
    [stats, definitely_bad, possibly_bad] = segment_bad_matches(matches, tformsA, tformsB, db_threshold, pb_threshold);
    z_matches = [z_matches; length(stats) length(definitely_bad) length(possibly_bad)];
end

