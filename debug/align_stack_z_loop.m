% Z Alignment
disp('==== <strong>Started Z alignment</strong>.')

% Align section pairs
for s = start:finish
    sec_timer = tic;
    fprintf('=== Aligning %s (<strong>%d/%d</strong>) in Z\n', secs{s}.name, s, length(sec_nums))
    
    % Parameters
    z_params = params(sec_nums(s)).z;
    
    % Keep fixed
    if strcmp(z_params.alignment_method, 'fixed')
        secB.alignments.z = fixed_alignment(secB, 'prev_z');
        secB.runtime.z.time_elapsed = toc(sec_timer);
        secB.runtime.z.timestamp = datestr(now);
        secs{s} = secB;
        continue
    elseif s==1
        secs{s}.alignments.z = fixed_alignment(secs{s}, 'rough_z_xy');
        secs{s}.runtime.z.timestamp = datestr(now);
    else
        [secs{s-1}, secs{s}] = align_stack_z_section_pair(secs{s-1}, secs{s}, z_params);
    end
    
end

% Save to cache
disp('=== Saving sections to disk.');
save_timer = tic;
filename = sprintf('%s_z_aligned.mat', secs{1}.wafer);
save(get_new_path(fullfile(cachepath, filename)), 'secs', '-v7.3')
fprintf('Saved to: %s [%.2fs]\n', fullfile(cachepath, filename), toc(save_timer))

secs{end} = imclear_sec(secs{end});