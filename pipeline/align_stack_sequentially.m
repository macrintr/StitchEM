%% set start % finish
start = 1; finish = 1;
sections = [start:finish];

%% rough xy alignment
for s=sections
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
for s=sections
    figure
    plot_section(secs{s}, secs{s}.alignments.rough_xy);
end

%% repair rough xy
s=start;
tile_num = 16;
secs{s} = repair_rough_xy_tile(secs{s}, tile_num);

%% xy alignment
for s=sections
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
for s=sections
    stats = plot_xy_matches_stats(secs{s});
    figure
    plot_section(secs{s}, secs{s}.alignments.xy);
end

%% cleanup xy
for s=sections
    secs = clean_xy_matches(secs, s, 20);
end

%% debug xy
for s=sections
    figure
    plot_section(secs{s}, secs{s}.alignments.rough_xy);
    plot_matches(secs{s}.xy_matches);
end

%% overview rough z alignment
for s=sections
    % Load overview for the sections
    secs{s} = load_overview(secs{s});
    if isempty(secs{s-1}.overview.img)
        secs{s-1} = load_overview(secs{s-1});
    end
    
    secs{s} = align_overview_rough_z(secs{s-1}, secs{s}, 1);
    
    % imwrite_overview_pair(secs{s-1}, secs{s}, 'initial', 'rough_z', 'overview_rough_z')
    secs{s} = imclear_sec(secs{s});
    secs{s-1} = imclear_sec(secs{s-1});   
end

%% check overview rough z
for s=sections
    imshow_overview_pair(secs{s-1}, secs{s}); 
end

%% rough z alignment
for s=sections
    secs{s} = align_rough_z(secs{s});
end

%% check rough z
for s=158
    imshow_section_pair(secs{s-1}, secs{s}, 'xy', 'rough_z');
end

%% z alignment
align_stack_z;

%% check z
for s=sections
    stats = plot_z_matches_stats(secs, s);
    plot_z_matches_global(secs{s-1}, secs{s});
end

%% cleanup z
for s=2:168
    secs = clean_z_matches(secs, s, 80);
end

%% debug z
for s=sections
    imshow_section_pair(secs{s-1}, secs{s}, 'z', 'prev_z');
end

%% propagate
for s=start
    secs = propagate_tforms_through_secs(secs, s);
end

%% save
filename = '150520_S2-W001-W002_affine_double_check.mat';
save(filename, 'secs', '-v7.3')