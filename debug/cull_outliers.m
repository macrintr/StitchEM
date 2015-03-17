%% Load secs
clearvars;
load('/home/tmacrina/StitchEM/results/S2-W001_z_aligned.mat')

%% Clean xy & z matches
log = cell(1, 1);

% Cycle through all sections for cleaning 
for i=20:20
    secB = secs{i};
    
    % Clean xy matches
    matches = secB.xy_matches;
    tformsA = secB.alignments.xy.tforms;
    tformsB = secB.alignments.xy.tforms;
    stats = calculate_matches_stats(matches, tformsA, tformsB);
    
    count = length(stats);
%     med = median(stats.dist);
%     sd = std(stats.dist);
    
    if count < 50
        log{end+1} = [secB.name ' has ' num2str(count) ' xy_matches'];
    else
        id_list = stats.id(stats.dist > 12, :);
        log{end+1} = [secB.name ' ' num2str(length(id_list)) ' xy_matches removed (dist > 12px)'];
        secB.xy_matches = remove_matches_by_id(secB.xy_matches, id_list);
        log{end+1} = [secB.name ' has ' num2str(height(secB.xy_matches.A)) ' xy_matches'];
    end
    
    if i > 1
        secA = secs{i-1};
        
        % Clean z matches
        matches = secB.z_matches;
        tformsA = secA.alignments.z.tforms;
        tformsB = secB.alignments.z.tforms;
        stats = calculate_matches_stats(matches, tformsA, tformsB);
            
        count = length(stats);
        
        if count < 30
            log{end+1} = [secB.name ' has ' num2str(count) ' z_matches'];
        else
            id_list = stats.id(stats.dist > 25, :);
            log{end+1} = [secB.name ' ' num2str(length(id_list)) ' z_matches removed (dist > 25px)'];
            secB.z_matches = remove_matches_by_id(secB.z_matches, id_list);
            log{end+1} = [secB.name ' has ' num2str(height(secB.z_matches.A)) ' z_matches'];
        end
    end
        
    secs{i} = secB;
end

%% Save results
filename = sprintf('%s_jitter_fix_z.mat', secs{1}.wafer);
save(filename, 'secs', '-v7.3');


%% Show results
stats = plot_all_z_matches_stats(secs, 2, 50);