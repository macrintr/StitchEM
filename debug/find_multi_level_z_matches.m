%% Load and initialize secs for multi-level z matches
W001;
load('S2-W001_clean_matches_1_10.mat')

%% Calculate multi-level z matches
increment_range = [-2:-1 2];

for i = 1:length(secs)
    for j = increment_range
        if i+j <= length(secs) & i+j >= 1
            z_params = params(i+j).z;
            
            secA = secs{i};
            secB = secs{i+j};
            
            % Load tile images
            if ~isfield(secA.tiles, 'z') || secA.tiles.z.scale ~= z_params.scale; secA = load_tileset(secA, 'z', z_params.scale); end
            if ~isfield(secB.tiles, 'z') || secB.tiles.z.scale ~= z_params.scale; secB = load_tileset(secB, 'z', z_params.scale); end
            
            % Detect features in overlapping regions
            secA.features.base_z = detect_features(secA, 'regions', sec_bb(secB, 'rough_xy'), 'alignment', 'rough_xy', 'detection_scale', z_params.scale, z_params.SURF);
            secB.features.z = detect_features(secB, 'regions', sec_bb(secA, 'rough_xy'), 'alignment', 'rough_xy', 'detection_scale', z_params.scale, z_params.SURF);
            
            % Match
            matches = match_z(secA, secB, 'base_z', 'z', z_params.matching);
            matches.A.section = (i) * ones(height(matches.A), 1);
            matches.B.section = (i+j) * ones(height(matches.B), 1);
            
            if j >= 0;
                level = sprintf('m%d', j);
            else
                level = sprintf('p%d', abs(j));
            end
            fieldname = ['z_' level '_matches'];
            secs{i+j}.(fieldname) = matches;
        end
    end
end

%% Clean up multi-level z matches
for i=1:length(secs)
    matches.A = table();
    matches.B = table();
    matches.details = cell(length(secs{i}.inter_z_matches), 1);
    for j=1:length(secs{i}.inter_z_matches)
        matches.A = [matches.A; secs{i}.inter_z_matches{j}.A];
        matches.B = [matches.B; secs{i}.inter_z_matches{j}.B];
        secs{i}.inter_z_matches{j}.A = [];
        secs{i}.inter_z_matches{j}.B = [];
        matches.details{j} = secs{i}.inter_z_matches{j};
    end
    secs{i}.multi_level_z_matches = matches;
    secs{i} = rmfield(secs{i}, 'inter_z_matches');
end

%% Reset global points to be local points
for i=1:length(secs)
    secs{i}.multi_level_z_matches.A.global_points = secs{i}.multi_level_z_matches.A.local_points;
    secs{i}.multi_level_z_matches.B.global_points = secs{i}.multi_level_z_matches.B.local_points;
end

%% Save secs object
filename = sprintf('%s_clean_matches_1_10_multi-level_z.mat', secs{1}.wafer);
save(filename, 'secs', '-v7.3');

%% Compile all matches & globally align
[matchesA, matchesB] = compile_matches(secs);
for i=1:length(secs)
    matchesA = [matchesA; secs{i}.multi_level_z_matches.A];
    matchesB = [matchesB; secs{i}.multi_level_z_matches.B];
end

secs = global_alignment(secs, matchesA, matchesB);

%% Visualize
plot_z_matches_global(secs{1}, secs{2});
