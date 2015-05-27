%% set start % finish
start = 56; finish = 57;

%% rough xy alignment
for s=start:finish
    % Check for params
    if ~exist('params'); error('The ''params'' variable does not exist. Load parameters before doing alignment.'); end
    xy_params = params(sec_nums(s)).xy;
    
    % Create a new section structure
    sec = load_section(sec_nums(s), 'skip_tiles', xy_params.skip_tiles, 'wafer_path', waferpath());
    
    % Rough alignment
    sec.alignments.rough_xy = align_rough_xy(sec);
    
    sec.params = params(sec_nums(s));
    secs{s} = sec;
end

%% check rough xy
for s=start:finish
    figure
    plot_section(secs{s}, secs{s}.alignments.rough_xy);
end

%% xy alignment
for s=start:finish
    sec_timer = tic;
    
    % Set sec variable
    sec = secs{s};
    xy_params = secs{s}.params.xy;
    
    % Load full resolution tiles
    if ~isfield(sec.tiles, 'full'); sec = load_tileset(sec, 'full', 1.0); end
    
    % Detect XY features
    sec.features.xy = detect_features(sec, 'alignment', 'rough_xy', 'regions', 'xy', xy_params.features);
    
    % Match XY features
    sec.xy_matches = match_xy(sec, 'xy', xy_params.matching);
    
    % Flag bad matching
    if sec.xy_matches.meta.avg_error > xy_params.max_match_error
        disp('<strong>FLAG</strong> XY matches distance beyond threshold');
        sec.error_log{end+1} = sprintf('%s: sec.xy_matches.meta.avg_error > xy_params.max_match_error', sec.name);
    end
    if ~isempty(find_orphan_tiles(sec, 'xy'))
        disp('<strong>FLAG</strong> XY orphan tiles');
        sec.error_log{end+1} = sprintf('%s: orphan tiles', sec.name);
    end

    try
        % Align XY
        sec.alignments.xy = align_xy(sec, xy_params.align);
        
        % Flag bad alignment
        if sec.alignments.xy.meta.avg_post_error > xy_params.max_aligned_error
            disp('<strong>FLAG</strong> XY alignment error above threshold');
        end
    catch
        fprintf('Failed xy alignment for %s_Sec%d', sec.wafer, sec.num);
    end
    
    % Clear images and XY features to save memory
    sec = imclear_sec(sec);
    sec.features.xy.tiles = [];
    
    % Save
    sec.params.xy = xy_params;
    sec.runtime.xy.time_elapsed = toc(sec_timer);
    sec.runtime.xy.timestamp = datestr(now);
    secs{s} = sec;
end

%% check xy
for s=start:finish
    stats = plot_xy_matches_stats(secs{s});
    figure
    plot_section(secs{s}, secs{s}.alignments.xy);
end

%% cleanup xy
for s=start:finish
    secs = clean_xy_matches(secs, s, 10);
end

%% debug xy
for s=start:finish
    figure
    plot_section(secs{s}, secs{s}.alignments.rough_xy);
    plot_matches(secs{s}.xy_matches);
end

%% overview rough z alignment
for i=start:finish
    % Load overview for the sections
    secs{i} = load_overview(secs{i});
    if isempty(secs{i-1}.overview.img)
        secs{i-1} = load_overview(secs{i-1});
    end
    
    secs{i} = align_overview_rough_z(secs{i-1}, secs{i}, 1);
    
    % imwrite_overview_pair(secs{i-1}, secs{i}, 'initial', 'rough_z', 'overview_rough_z')
    
    secs{i} = imclear_sec(secs{i});
    secs{i-1} = imclear_sec(secs{i-1});
end

%% check overview rough z
for s=start:finish
    imshow_overview_pair(secs{s-1}, secs{s});
end

%% rough z alignment
for i=start:finish
    secs{i} = align_rough_z(secs{i});
end

%% check rough z
for s=start:finish
    imshow_section_pair(secs{s-1}, secs{s}, 'xy', 'rough_z');
end

%% z alignment
align_stack_z;

%% check z
for s=start:finish
    stats = plot_z_matches_stats(secs, s);
    plot_z_matches_global(secs{s-1}, secs{s});
end

%% cleanup z
for s=start:finish
    secs = clean_z_matches(secs, s);
end

%% debug z
for s=start:finish
    imshow_section_pair(secs{s-1}, secs{s}, 'z', 'prev_z');
end

%% propagate
for s=start:finish
    secs = propagate_tforms_through_secs(secs, s);
end