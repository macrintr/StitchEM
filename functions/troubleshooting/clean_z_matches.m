function secs = clean_z_matches(secs, s, threshold)
% Clean xy & z matches of sec #s

if nargin < 3
    threshold = 120;
end

% Set thresholds
z_definitely_bad = threshold;
z_possibly_bad = 80;
alignment_type = 'z';
if s > 1 && width(secs{s}.z_matches.A) < 3
    secs{s}.z_matches = transform_z_matches_inverse(secs, s);
end

k = secs{s}.params.z.rel_to;
matches_type = [alignment_type '_matches'];
db_threshold = z_definitely_bad;
pb_threshold = z_possibly_bad;

disp(['<strong>Section ' num2str(s) ': ' matches_type '</strong>']);

% Segment, downsample, remove, inspect, & remove matches
disp('<strong>Segment matches</strong>');
% matches = secs{s}.(matches_type); % store in case of reset
tformsA = secs{s+k}.alignments.(alignment_type).tforms;
tformsB = secs{s}.alignments.(alignment_type).tforms;
[stats, definitely_bad, possibly_bad] = segment_bad_matches(secs{s}.(matches_type), tformsA, tformsB, db_threshold, pb_threshold);

% Remove definitely_bad matches
% Assigns xy_matches first, then append automatic_outliers
disp(['<strong>Removing ' num2str(length(definitely_bad)) ' definitely bad matches</strong>']);
[secs{s}.(matches_type), secs{s}.(matches_type).automatic_outliers] = remove_matches_by_id(secs{s}.(matches_type), definitely_bad.id);

disp('<strong>Realign z section</strong>');
secs{s}.alignments.z = align_z_pair_lsq(secs{s});