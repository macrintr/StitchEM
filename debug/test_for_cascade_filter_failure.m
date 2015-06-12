% test for cascade filter failure
renderpath('/usr/people/tmacrina/seungmount/research/tommy/150528_zfish/150608_test_bad_correspondences/');

filters = [200, 100, 20, 10];
avg_error = cell(length(secs), 1);

for s = 1:length(secs)
    
    xy_params = secs{s}.params.xy;
    
    if ~isfield(secs{s}.tiles, 'full'); secs{s} = load_tileset(secs{s}, 'full', 1.0); end
    
    % Detect XY features
    secs{s}.features.xy = detect_features(secs{s}, 'alignment', 'rough_xy', 'regions', 'xy', xy_params.features);
    
    % Match XY features
    secs{s}.xy_matches = match_xy(secs{s}, 'xy', xy_params.matching);
    
    secs{s}.features.xy.tiles = []; 
    secs{s} = imclear_sec(secs{s});
    
    avg_error{s}.pre = cell(length(filters), 1);
    avg_error{s}.post = cell(length(filters), 1);
    
    try
        secs{s}.alignments.xy = align_xy(secs{s}, xy_params.align);
        avg_error{s}.pre{1} = secs{s}.alignments.xy.meta.avg_prior_error;
        avg_error{s}.post{1} = secs{s}.alignments.xy.meta.avg_post_error;
        imwrite_section_plot(secs{s}, 'xy', 'overview_rough_z');
        imwrite_xy_residuals(secs{s}, 'overview_rough_z');
    end
    
    for f = 1:length(filters)
        fprintf('xy alignment for %s_Sec%d with %d filter\n', secs{s}.wafer, secs{s}.num, filters(f));
        
        dir = 'overview_rough_z';
        switch f
            case 1
                dir = 'rough_xy';
            case 2
                dir = 'rough_z';
            case 3
                dir = 'xy';
            case 4
                dir = 'z';
            otherwise
                dir = 'overview_rough_z';
        end
        
        try
            % Align XY
            secs = clean_xy_matches(secs, s, filters(f));
            avg_error{s}.pre{f+1} = secs{s}.alignments.xy.meta.avg_prior_error;
            avg_error{s}.post{f+1} = secs{s}.alignments.xy.meta.avg_post_error;
            
            % Export xy check
            imwrite_section_plot(secs{s}, 'xy', dir);
            imwrite_xy_residuals(secs{s}, dir);
        catch
            fprintf('Failed xy alignment for %s_Sec%d\n', secs{s}.wafer, secs{s}.num);
            imwrite_error_message(secs{s}, 'xy', dir);
        end
        
    end
end