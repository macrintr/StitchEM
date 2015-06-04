function secs = clean_xy_matches(secs, i, threshold)
% Clean xy & z matches of sec #i

if nargin < 3
    threshold = 20;
end

% Set thresholds
xy_definitely_bad = threshold;
xy_possibly_bad = 3;

alignment_type = 'xy';
matches_type = [alignment_type '_matches'];
j = i;
db_threshold = xy_definitely_bad;
pb_threshold = xy_possibly_bad;

if j > 0
    disp(['<strong>Section ' num2str(i) ': ' matches_type '</strong>']);
    
    % Segment, downsample, remove, inspect, & remove matches
    disp('<strong>Segment matches</strong>');
    % matches = secs{i}.(matches_type); % store in case of reset
    tformsA = secs{j}.alignments.(alignment_type).tforms;
    tformsB = secs{i}.alignments.(alignment_type).tforms;
    [stats, definitely_bad, possibly_bad] = segment_bad_matches(secs{i}.(matches_type), tformsA, tformsB, db_threshold, pb_threshold);
    
    % Remove definitely_bad matches
    % Assigns xy_matches first, then append automatic_outliers
    disp(['<strong>Removing ' num2str(length(definitely_bad)) ' definitely bad matches</strong>']);
    [secs{i}.(matches_type), secs{i}.(matches_type).automatic_outliers] = remove_matches_by_id(secs{i}.(matches_type), definitely_bad.id);
    
    disp('<strong>Realign xy section</strong>');
    secs{i}.alignments.xy = align_xy(secs{i});
end