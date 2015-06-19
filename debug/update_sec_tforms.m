function secs = update_sec_tforms(secs, s, rough_z_tform_type, z_tform_type)
% Propagate tforms through one section, starting with rough_xy
%
% Inputs
%   secs: cell array of section structs
%   s: cell array index of section to update
%   rough_z_tform_type: rough_z affine or rigid requirement
%   z_tform_type: z affine or rigid requirement
%
% Output
%   secs
%
% secs = update_sec_tforms(secs, s, rough_z_tform_type, z_tform_type)

if nargin < 3
    rough_z_tform_type = 'affine';
    z_tform_type = 'affine';
end

% % Transform xy matches into rough_xy, if necessary
% tforms = secs{s}.alignments.rough_xy.tforms;
% secs{s}.xy_matches = transform_matches(secs{s}.xy_matches, tforms, tforms);
% 
% % Update xy alignment
% if isfield(secs{s}.alignments.xy, 'manual')
%     rel_tforms = secs{s}.alignments.xy.rel_tforms;
%     secs{s}.alignments.xy.tforms = cellfun(@(rough, rel) compose_tforms(rough, rel), tforms, rel_tforms, 'UniformOutput', false);
% else
%     secs{s}.alignments.xy = align_xy(secs{s});
% end

% Update tform type of overview rough_z
secs{s}.overview.alignments.rough_z = realign_overview_rough_z(secs{s}, rough_z_tform_type);

% Compose updated xy with overview_rough_z to update rough_z
num_tiles = size(secs{s}.alignments.xy.tforms, 1);
rel_tforms_z = {};
for i=1:num_tiles
    rel_tforms_z{end+1} = secs{s}.overview.alignments.rough_z.tform;
end
rel_tforms_z = rel_tforms_z';

tforms_z_xy = cellfun(@(rough, rel) compose_tforms(rough, rel), secs{s}.alignments.xy.tforms, rel_tforms_z, 'UniformOutput', false);
secs{s}.alignments.rough_z.tforms = tforms_z_xy;
secs{s}.alignments.rough_z.rel_tforms = rel_tforms_z;

if s == 1
    secs{s}.alignments.prev_z = fixed_alignment(secs{s}, 'rough_z');
    secs{s}.alignments.z = fixed_alignment(secs{s}, 'rough_z');
else
    secs{s}.alignments.prev_z = compose_alignments(secs{s-1}, {'rough_z', 'prev_z', 'z'}, secs{s}, 'rough_z');
%     secs{s}.z_matches = transform_matches(secs{s}.z_matches, secs{s-1}.alignments.z.tforms, secs{s}.alignments.prev_z.tforms);
%     secs{s}.alignments.z = align_z_pair_lsq(secs{s}, 'prev_z', z_tform_type);
    secs{s}.z_matches = transform_matches(secs{s}.z_matches, secs{s-1}.alignments.z.tforms, secs{s}.alignments.xy.tforms);
    secs{s}.alignments.z = align_z_pair_lsq(secs{s}, 'xy', z_tform_type);

    missing_tile_numbers = find(~secs{s-1}.grid);
    index_of_missing_tile = secs{s}.grid(missing_tile_numbers);
    if index_of_missing_tile
        fprintf('Missing tile % ', index_of_missing_tile)
        secs{s} = propagate_z_for_missing_tiles(secs{s-1}, secs{s});
    end
end