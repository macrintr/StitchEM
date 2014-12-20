sections_to_repair = [3];
for s = sections_to_repair
    sec = secs{s};
    i = 2;
    while secs{s}.grid ~= secs{s-i}.grid
    	i = i-1;
    end
    sec.alignments.rough_xy = secs{s-i}.alignments.rough_xy;
    sec.alignments.rough_xy.copied_from = secs{s-i}.num;
    sec.alignments.rough_xy.copy_reason = 'overview registration failure';
    
    % Load parameters
    xy_params = params(sec_nums(s)).xy;
    
    % Load tiles
    sec = load_tileset(sec, 'full', 1.0);
    
    % Detect XY features
    sec.features.xy = detect_features(sec, 'alignment', 'rough_xy', 'regions', 'xy', xy_params.features);
    
    % Match XY features
    sec.xy_matches = match_xy(sec, 'xy', xy_params.matching);
    
    % Clear images before saving to memory
    sec = imclear_sec(sec);
    sec.features.xy.tiles = [];
    
    reprocess_xy_new_matches;
end
        
        