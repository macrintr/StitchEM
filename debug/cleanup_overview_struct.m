for i=1:length(secs)
    if isfield(secs{i}.overview, 'alignment')
        secs{i}.overview.alignments.initial = secs{i}.overview.alignment;
        secs{i}.overview = rmfield(secs{i}.overview, 'alignment');
    end
    if isfield(secs{i}.overview, 'rough_align_z')
        secs{i}.overview.alignments.rough_z = secs{i}.overview.rough_align_z;
        secs{i}.overview = rmfield(secs{i}.overview, 'rough_align_z');
        secs{i}.overview.alignments.rough_z.tform = secs{i}.overview.alignments.rough_z.tforms;
        secs{i}.overview.alignments.rough_z.rel_tform = secs{i}.overview.alignments.rough_z.rel_tforms;
        secs{i}.overview.alignments.rough_z = rmfield(secs{i}.overview.alignments.rough_z, 'tforms');
        secs{i}.overview.alignments.rough_z = rmfield(secs{i}.overview.alignments.rough_z, 'rel_tforms');
    end
    if isfield(secs{i}.overview, 'scale')
        secs{i}.overview = rmfield(secs{i}.overview, 'scale');
        secs{i}.overivew.overview_to_tile_resolution_ratio = 0.07;
    end
    if isfield(secs{i}, 'overview_to_tile_resolution_ratio')
        secs{i} = rmfield(secs{i}, 'overview_to_tile_resolution_ratio');
    end
end