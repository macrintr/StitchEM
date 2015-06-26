function secB = propagate_z_for_missing_tiles(secA, secB, use_intermediaries)
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

if nargin < 3
    use_intermediaries = false;
end

missing_tile_numbers = find(~secA.grid)';
index_of_missing_tile = secB.grid(missing_tile_numbers);

% Need to propagate from a non-missing tile
[r, c] = find(secA.grid, 1);
first_non_missing = secA.grid(r, c); 

prev_z_rel = secB.alignments.prev_z.rel_tforms{first_non_missing};
z_rel = secB.alignments.z.rel_tforms{first_non_missing};

for i=index_of_missing_tile   
    rough_z = secB.alignments.rough_z.tforms{i};
    prev_z = affine2d(rough_z.T * prev_z_rel.T);   
    
    if use_intermediaries
        z = affine2d(prev_z.T * z_rel.T);
    else
        xy = secB.alignments.xy.tforms{i};
        z = affine2d(xy.T * z_rel.T);
    end
    
    secB.alignments.prev_z.rel_tforms{i} = prev_z_rel;
    secB.alignments.prev_z.tforms{i} = prev_z;    
    
    secB.alignments.z.tforms{i} = z;
    secB.alignments.prev_z.repairs = mfilename;
    secB.alignments.z.repairs = mfilename;
end

% render_section_pairs(secA, secB, 1);