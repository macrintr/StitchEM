%% Rough & XY Alignment
if ~exist('secs'); secs = cell(length(sec_nums), 1); end
start = 123;
finish = length(sec_nums);

disp('==== <strong>Starting rough xy, xy, & rough z alignment</strong>.')
for s = start:finish
    fprintf('=== Aligning %s (<strong>%d/%d</strong>) in XY\n', get_path_info(get_section_path(sec_nums(s)), 'name'), s, length(sec_nums))
    
    % Section structure & parameters
    % Check for params
    if ~exist('params'); error('The ''params'' variable does not exist. Load parameters before doing alignment.'); end
    xy_params = params(sec_nums(s)).xy;
    
    % Create a new section structure
    secs{s} = load_section(sec_nums(s), 'skip_tiles', xy_params.skip_tiles, 'wafer_path', waferpath());
    
    % Load images
    if ~isfield(secs{s}.tiles, 'full'); secs{s} = load_tileset(secs{s}, 'full', 1.0); end
    if isempty(secs{s}.overview) || ~isfield(secs{s}.overview, 'img') || isempty(secs{s}.overview.img)
        secs{s} = load_overview(secs{s});
    end
    
    % Rough alignment
    secs{s}.alignments.rough_xy = align_rough_xy(secs{s});
    
    % Export rough xy check
    imwrite_section_plot(secs{s}, 'rough_xy', 'rough_xy');

    fprintf('xy alignment for %s_Sec%d\n', secs{s}.wafer, secs{s}.num);
    % Detect XY features
    secs{s}.features.xy = detect_features(secs{s}, 'alignment', 'rough_xy', 'regions', 'xy', xy_params.features);
    
    % Match XY features
    secs{s}.xy_matches = match_xy(secs{s}, 'xy', xy_params.matching);

    try
        % Align XY
        secs{s}.alignments.xy = align_xy(secs{s}, xy_params.align);
        % Export xy check
        imwrite_section_plot(secs{s}, 'xy', 'xy');
        imwrite_xy_residuals(secs{s}, 'xy')
    catch
        fprintf('Failed xy alignment for %s_Sec%d', secs{s}.wafer, secs{s}.num);
    end
    
    % Clear XY features to save memory
    secs{s}.features.xy.tiles = [];
    
    % Save params
    secs{s}.params = params(sec_nums(s));
    
    fprintf('Rough z alignment for %s_Sec%d\n', secs{s}.wafer, secs{s}.num);
    % Overview rough alignment
    if s==1
        alignment.tform = secs{s}.overview.alignments.initial.tform;
        alignment.rel_tform = affine2d();
        alignment.rel_to = 'initial';
        alignment.method = 'fixed';
        
        secs{s}.overview.alignments.rough_z = alignment;
    else
        secs{s} = align_overview_rough_z(secs{s-1}, secs{s});
        imwrite_overview_pair(secs{s-1}, secs{s}, 'initial', 'rough_z', 'overview_rough_z');
        secs{s-1} = imclear_sec(secs{s-1});
    end
    
    secs{s} = align_rough_z(secs{s});
    
    secs{s}.runtime.xy.timestamp = datestr(now);
end

secs{finish} = imclear_sec(secs{finish});

disp('==== <strong>Finished rough xy, xy, & rough z alignment</strong>.')
