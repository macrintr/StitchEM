function alignment = realign_overview_rough_z(sec, tform_type)
% Realign overview rough_z using an alternative method
%
% Inputs
%   sec: section struct
%   method: either 'affine' or 'rigid'
%
% Outputs
%   alignment: new alignment struct for sec.overview.alignments.rough_z
%
% alignment = realign_overview_rough_z(sec, method)

alignment = sec.overview.alignments.rough_z;
data = alignment.data;

fprintf('Realigning %s overview rough_z as <strong>%s</strong>\n', sec.name, tform_type);

if strcmp(tform_type, 'rigid')
    P = [data.moving_inliers ones(length(data.moving_inliers), 1)]';
    Q = [data.fixed_inliers ones(length(data.fixed_inliers), 1)]';
    [U, r, lrms] = Kabsch(P, Q);
    T = [U(1:2, 1:2) r(1:2); [0 0 1]]';
    tform_moving = affine2d(T);
else
    tform_moving = fitgeotrans(data.moving_inliers, data.fixed_inliers, 'nonreflectivesimilarity');
end
    
% Rescale the tform
% First to the appropriate level for display
s = data.overview_scale;
S = [s 0 0; 0 s 0; 0 0 1];
tform_rescaled_display = affine2d(S * tform_moving.T * S^-1);

% Adjust transform for initial transform (should be no change)
% tform_final_overview = compose_tforms(secA.overview.alignments.initial.tform, tform_rescaled_display);

% Save to data structure
alignment.tform = tform_rescaled_display; %tform_final_overview;
alignment.rel_tform = tform_rescaled_display;
alignment.tform_type = tform_type;
alignment.data = data;