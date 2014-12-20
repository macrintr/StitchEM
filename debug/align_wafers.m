%% Configuration
% Load data
cache = load(waferA, 'secs');
secsA = cache.secs;
cache = load(waferB, 'secs');
secsB = cache.secs;
wafers = {secsA, secsB};
clear cache secsA secsB
disp('Loaded wafers.')

%% Merge
for w = 1:length(wafers)
    % First wafer is the reference
    if w == 1
        for s = 1:length(wafers{w})
            wafers{w}{s}.alignments.stack_z = fixed_alignment(wafers{w}{s}, 'z', 0);
        end
        fprintf('Keeping <strong>%s</strong> fixed.\n', wafers{w}{1}.wafer)
        continue
    end
    secsA = wafers{w - 1};
    secsB = wafers{w};
    fprintf('Aligning <strong>%s</strong> to <strong>%s</strong>.\n', secsB{1}.wafer, secsA{1}.wafer)
    
    % Get end sections
    secA = secsA{end};
    secB = secsB{1};
    
    % Rough align sections
    secB.overview = rmfield(secB.overview, 'rough_align_z');
    secB = rough_align_z_section_pair(secA, secB);
    
    % Set prev_z as identity
    secB.alignments.prev_z = fixed_alignment(secB, 'rough_z_xy', 0);
    
    % Compose with previous
    secB.alignments.prev_stack_z = compose_alignments(secA, {'prev_z', 'z'}, secB, 'z');
    
    % Automatically detect features
    secA.features.base_z = detect_features(secA, 'regions', sec_bb(secB, 'prev_stack_z'), 'alignment', 'stack_z', 'detection_scale', z_params.scale, z_params.SURF);
    secB.features.z = detect_features(secB, 'regions', sec_bb(secA, 'stack_z'), 'alignment', 'prev_stack_z', 'detection_scale', z_params.scale, z_params.SURF);
    secB.z_matches = match_z(secA, secB, 'base_z', 'stack_z', z_params.matching);
    
    % Align those auto matches
    secB.alignments.stack_z = align_z_pair_cpd(secB, secB.stack_z_matches, 'prev_stack_z');  
    
    % Construct a questdlg with three options
    choice = questdlg('Is this alignment acceptable? If no, you will be prompted to select matches manually.', ...
        'Alignment Acceptance', ...
        'Yes','No','Yes');
    % Handle response
    switch choice
        case 'Yes'
            continue
        case 'No'
            % Manually select matches
            secB.stack_z_matches = select_z_matches(secA, secB, 'stack');
            % Align those manual matches
            secB.alignments.stack_z = align_z_pair_cpd(secB, secB.stack_z_matches, 'prev_stack_z');
    end
    
    secsB{1} = secB;
    
    % Propagate to the rest of the wafer
    for s = 2:length(secsB)
        secsB{s}.alignments.stack_z = compose_alignments(secsB{1}, {'prev_stack_z', 'stack_z'}, secsB{s}, 'z');
    end
    
    % Save
    wafers{w} = secsB;
    fprintf('Aligned <strong>%s</strong> to <strong>%s</strong>.\n', secsB{1}.wafer, secsA{1}.wafer)
    clear secsA secsB secA secB
end