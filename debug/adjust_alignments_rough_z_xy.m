for i=1:length(secs)
    if isfield(secs{i}.alignments, 'rough_z_xy')
        secs{i}.alignments.rough_z = secs{i}.alignments.rough_z_xy;
        secs{i}.alignments = rmfield(secs{i}.alignments, 'rough_z_xy');
    end
end