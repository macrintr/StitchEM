for s=start:finish
    if s==1
        z_alignment.tforms = affine2d();
        z_alignment.rel_tforms = affine2d();
        z_alignment.rel_to = 'None';
        z_alignment.rel_to_sec = 'None';
        z_alignment.method = 'rough_align_z';
        secs{s}.overview.rough_align_z = z_alignment;
        
        secs{s}.alignments.rough_z_xy = fixed_alignment(secs{s}, 'xy');
        secs{s} = load_overview(secs{s}, secs{s}.overview.scale);
        
    else
        [secs{s-1}, secs{s}] = rough_align_z_section_pair(secs{s-1}, secs{s});
    end
end

secs{end}.overview.img = [];