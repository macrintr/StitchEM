function secB = propagate_z_for_missing_tiles(secA, secB)
% Propagate alignments when one middle section is missing one tile or more
%
% Inputs:
%   secA: the section with completed z-alignment and missing tile
%   secB: full section that needs propagated z-alignment
%
% After discovering an improperly propagated z alignment because of a
% missing tile, you run this repair script, with secB as the section that
% needs to be repaired. Then you restart the fine z alignment at the
% section immediately following secB.

missing_tile_numbers = find(~secA.grid)';
index_of_missing_tile = secB.grid(missing_tile_numbers);

% Need to propagate from a non-missing tile
[r, c] = find(secA.grid, 1);
first_non_missing = secA.grid(r, c); 
prev_z_align_secB = secB.alignments.prev_z.rel_tforms{first_non_missing};
z_align_secB = secB.alignments.z.rel_tforms{first_non_missing};

for i=index_of_missing_tile
    rough_z_align_secB = secB.alignments.rough_z_xy.tforms{i};

    prev_z_tform_missing = affine2d(rough_z_align_secB.T * prev_z_align_secB.T);
    z_tform_missing = affine2d(prev_z_tform_missing.T * z_align_secB.T);  
    
    secB.alignments.prev_z.rel_tforms{i} = prev_z_align_secB;
    secB.alignments.prev_z.tforms{i} = prev_z_tform_missing;
    secB.alignments.z.tforms{i} = z_tform_missing;
    secB.alignments.prev_z.repairs = 'propagate_z_for_missing_tiles';
    secB.alignments.z.repairs = 'propagate_z_for_missing_tiles';    
end

% render_section_pairs(secA, secB, 1);