%% Configuration
waferA = '/home/tmacrina/StitchEM/results/S2-W001_z_aligned.mat';
waferB = '/home/tmacrina/StitchEM/results/S2-W002_z_aligned.mat';

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
    
    % Align
    secB.stack_z_matches = select_z_matches(secA, secB, 'stack');
    secB.alignments.stack_z = align_z_pair_cpd(secB, secB.stack_z_matches, 'prev_stack_z');
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