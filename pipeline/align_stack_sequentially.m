%% rough xy alignment
for i=start:finish
    % Section structure & parameters
    if length(secs) < s && ~exist('sec') || sec.num ~= sec_nums(s)
        % Check for params
        if ~exist('params'); error('The ''params'' variable does not exist. Load parameters before doing alignment.'); end
        xy_params = params(sec_nums(s)).xy;        
        
        % Create a new section structure
        sec = load_section(sec_nums(s), 'skip_tiles', xy_params.skip_tiles, 'wafer_path', waferpath());
    else
        % Check for params
        xy_params = sec{s}.params.xy;
        
        % Use section in the workspace
    	sec = secs{s};
        disp('Using section that was already loaded. Clear ''sec'' to force section to be reloaded.')
    end
    
    % Load images
    if ~isfield(sec.tiles, 'full'); sec = load_tileset(sec, 'full', 1.0); end
    if ~isfield(sec.tiles, 'rough'); sec = load_tileset(sec, 'rough', xy_params.rough.overview_registration.tile_scale); end
    if isempty(sec.overview) || ~isfield(sec.overview, 'img') || isempty(sec.overview.img)
        sec = load_overview(sec);
    end
    
    % Rough alignment
    sec.alignments.rough_xy = rough_align_xy(sec, xy_params.rough);
end

%% xy alignment
for i=start:finish
    
end

%% rough overview z alignment
for i=start:finish
    % Load overview for the sections
    secs{i} = load_overview(secs{i});
    if isempty(secs{i-1}.overview.img)
        secs{i-1} = load_overview(secs{i-1});
    end
    
    secB = align_overview_rough_z(secs{i-1}, secs{i});
    
    imwrite_overview_pair(secs{i-1}, secs{i}, 'initial', 'rough_z', 'overview_rough_z')
    secs{i-1} = imclear(secs{i-1});
end

%% rough z alignment
for i=start:finish
    secB = align_rough_z(secB);
end

%% z alignment
for i=start:finish
    
end