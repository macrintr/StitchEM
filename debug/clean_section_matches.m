function secs = clean_section_matches(secs, i)
% Clean xy & z matches of sec #i

% Set thresholds
xy_definitely_bad = 10;
xy_possibly_bad = 3;
z_definitely_bad = 200;
z_possibly_bad = 200;

xy_count_limit = 600; % 25 matches per seam (24 seams)
z_count_limit = 400; % 25 matches per pair (16 pairs)

if i > 1 && width(secs{i}.z_matches.A) < 3
    secs{i}.z_matches = transform_z_matches_inverse(secs, i);
end

for matches_idx = 2:2
    if matches_idx == 1
        alignment_type = 'xy';
    else
        alignment_type = 'z';
    end
    
    matches_type = [alignment_type '_matches'];
    if strcmp(alignment_type, 'xy')
        j = i;
        count_limit = xy_count_limit;
        db_threshold = xy_definitely_bad;
        pb_threshold = xy_possibly_bad;
        scale = 1.0;
    else
        j = i-1; % z matches are with the layer before
        count_limit = z_count_limit;
        db_threshold = z_definitely_bad;
        pb_threshold = z_possibly_bad;
        scale = 0.5;
    end
    
    if j > 0
        disp(['<strong>Section ' num2str(i) ': ' matches_type '</strong>']);
        
        % Segment, downsample, remove, inspect, & remove matches
        disp('<strong>Segment matches</strong>');
        % matches = secs{i}.(matches_type); % store in case of reset
        tformsA = secs{j}.alignments.(alignment_type).tforms;
        tformsB = secs{i}.alignments.(alignment_type).tforms;
        [stats, definitely_bad, possibly_bad] = segment_bad_matches(secs{i}.(matches_type), tformsA, tformsB, db_threshold, pb_threshold);
        
%         count = length(stats);
%         if count > count_limit
%             disp('<strong>Downsampling</strong>');
%             count_percentage = 1 - count_limit ./ count;
%             
%             id_list = downsample_matches(stats, count_percentage);
%             secs{i}.(matches_type) = remove_matches_by_id(secs{i}.(matches_type), id_list);
%             
%             [stats, definitely_bad, possibly_bad] = segment_bad_matches(secs{i}.(matches_type), tformsA, tformsB, db_threshold, pb_threshold);
%         end
        
        % Remove definitely_bad matches
        % Assigns xy_matches first, then append automatic_outliers
        disp(['<strong>Removing ' num2str(length(definitely_bad)) ' definitely bad matches</strong>']);
        [secs{i}.(matches_type), secs{i}.(matches_type).automatic_outliers] = remove_matches_by_id(secs{i}.(matches_type), definitely_bad.id);
        
        if strcmp(alignment_type, 'xy')
            disp('<strong>Realign xy section</strong>');
            secs{i}.alignments.xy = align_xy(secs{i});
        else
            disp('<strong>Realign z section</strong>');
            secs{i}.alignments.z = align_z_pair_lsq(secs{i});
        end
%         secs = propagate_tforms(secs, i);
        
    end
end