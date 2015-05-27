function secs = clean_z_matches(secs, i, threshold)
% Clean xy & z matches of sec #i

if nargin < 3
    threshold = 120;
end

% Set thresholds
z_definitely_bad = threshold;
z_possibly_bad = 80;
alignment_type = 'z';
if i > 1 && width(secs{i}.z_matches.A) < 3
    secs{i}.z_matches = transform_z_matches_inverse(secs, i);
end
j = i-1; % z matches are with the layer before
matches_type = [alignment_type '_matches'];
db_threshold = z_definitely_bad;
pb_threshold = z_possibly_bad;

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
    
    disp('<strong>Realign z section</strong>');
    secs{i}.alignments.z = align_z_pair_lsq(secs{i});
end