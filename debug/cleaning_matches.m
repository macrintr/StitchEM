%% Load secs
% clearvars;
% clc;
% files = {'/home/tmacrina/StitchEM/results/S2-W007_z_aligned.mat';
%          '/home/tmacrina/StitchEM/results/S2-W008_z_aligned.mat'};

%% Set thresholds
xy_definitely_bad = 10;
xy_possibly_bad = 3;
z_definitely_bad = 120;
z_possibly_bad = 30;

xy_count_limit = 600; % 25 matches per seam (24 seams)
z_count_limit = 400; % 25 matches per pair (16 pairs)

%% Setup segments and matches type
% Took about 2.5hrs for all 167 sections in W001

% for n=1:length(files)
%     load(files{n});
%     if n==1
%         W007;
%     else
%         W008;
%     end
%         
%     movie_storage = cell(length(secs), 2);
%     
%     for k = [2:10:length(secs)]
start = 1;
finish = length(secs); %min(start + 9, length(secs));
% try
for i = start:finish
    
    if i > 1 && width(secs{i}.z_matches.A) < 3
        secs{i}.z_matches = transform_z_matches_inverse(secs, i);
    end
    
    for matches_idx = 1:2
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
            
            count = length(stats);
            if count > count_limit
                disp('<strong>Downsampling</strong>');
                count_percentage = 1 - count_limit ./ count;
                
                id_list = downsample_matches(stats, count_percentage);
                secs{i}.(matches_type) = remove_matches_by_id(secs{i}.(matches_type), id_list);
                
                [stats, definitely_bad, possibly_bad] = segment_bad_matches(secs{i}.(matches_type), tformsA, tformsB, db_threshold, pb_threshold);
            end
            
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
            secs = propagate_tforms(secs, i);
            
%             tformsA = secs{j}.alignments.(alignment_type).tforms;
%             tformsB = secs{i}.alignments.(alignment_type).tforms;
%             [stats, definitely_bad, possibly_bad] = segment_bad_matches(secs{i}.(matches_type), tformsA, tformsB, db_threshold, pb_threshold);
%             
            % Inspect possibly_bad matches
%             disp(['<strong>Inspecting ' num2str(length(possibly_bad)) ' possibly bad matches</strong>']);
%             if length(possibly_bad) > 0
%                 [s, idx] = sort(possibly_bad.dist, 'descend');
%                 movie_storage{i, matches_idx} = imshow_matches(secs{j}, secs{i}, possibly_bad(idx, :), scale);
%             end
        end
    end
end

% Save matches movie
% disp('<strong>Saving matches movies</strong>');
% filename = ['/mnt/data0/tommy/' secs{1}.wafer '/' secs{1}.wafer '_matches_movie_' num2str(start) '_' num2str(finish) '.mat'];
% save(filename, 'movie_storage', 'start', 'finish', '-v7.3');

% disp('<strong>Saving secs struct</strong>');
% filename = [secs{1}.wafer '_clean_matches.mat'];
% save(filename, 'secs', '-v7.3');
% end
%     end
% end

% %% Look through possibly_bad matches
% for i = start:finish
%     for matches_idx = 1:2
%         if matches_idx == 1
%             alignment_type = 'xy';
%         else
%             alignment_type = 'z';
%         end
%         
%         matches_type = [alignment_type '_matches'];
%         if strcmp(alignment_type, 'xy')
%             j = i;
%             count_limit = xy_count_limit;
%             db_threshold = xy_definitely_bad;
%             pb_threshold = xy_possibly_bad;
%             scale = 1.0;
%         else
%             j = i-1; % z matches are with the layer before
%             count_limit = z_count_limit;
%             db_threshold = z_definitely_bad;
%             pb_threshold = z_possibly_bad;
%             scale = 0.5;
%         end
%         
%         disp(['<strong>Section ' num2str(i) ': ' matches_type '</strong>']);
%         
%         disp('<strong>Matches in this section</strong>');
%         new_tformsA = secs{j}.alignments.(alignment_type).tforms;
%         new_tformsB = secs{i}.alignments.(alignment_type).tforms;
%         [stats, definitely_bad, possibly_bad] = segment_bad_matches(secs{i}.(matches_type), new_tformsA, new_tformsB, db_threshold, pb_threshold);
%         
%         implay(movie_storage{i, matches_idx}, 1)
%         id_list = enter_array(); % Exit function by pressing '0' then 'Enter'
%         
%         disp(['Removing ' num2str(length(id_list)) ' inspected matches']);
%         [secs{i}.(matches_type), secs{i}.(matches_type).inspected_outliers] = remove_matches_by_id(secs{i}.(matches_type), id_list);
%         
%         if strcmp(alignment_type, 'xy')
%             disp('<strong>Realign xy section</strong>');
%             secs{i}.alignments.xy = align_xy(secs{i});
%         else
%             if i > 1
%                 disp('<strong>Realign z section</strong>');
%                 secs{i}.alignments.z = align_z_pair_lsq(secs{i});
%             end
%         end
%     end
% end
% 
% % Save section
% disp('<strong>Saving secs struct</strong>');
% filename = 'S2-W002_clean_matches_with_W003_Sec1.mat';
% save(filename, 'secs', '-v7.3');
% 
% %% Load movie
% disp('<strong>Loading movie</strong>');
% load('/mnt/data0/tommy/S2-W002/S2-W002_matches_movie_2_11.mat');
% 
% %% Save section
% disp('<strong>Saving secs struct</strong>');
% filename = 'S2-W002_clean_matches_with_W003_Sec1.mat';
% save(filename, 'secs', '-v7.3');
% 
% %% Load section
% disp('<strong>Loading secs struct</strong>');
% load('S2-W002_clean_matches_with_W003_Sec1.mat');
% 
% %% Compare
% i = start;
% j = start;
% alignment_type = 'xy';
% matches_type = 'xy_matches';
% scale = 1.0;
% 
% db_threshold = xy_definitely_bad;
% pb_threshold = xy_possibly_bad;
% 
% tformsA = secs{j}.alignments.(alignment_type).tforms;
% tformsB = secs{i}.alignments.(alignment_type).tforms;
% [stats, definitely_bad, possibly_bad] = segment_bad_matches(secs{i}.(matches_type), tformsA, tformsB, db_threshold, pb_threshold);
% 
% [s, idx] = sort(possibly_bad.dist, 'descend');
% mov = imshow_matches(secs{j}, secs{i}, possibly_bad(idx, :), scale);
% implay(mov, 1);
% 
% implay(movie_storage{i, 1}, 1)