function matches = ransac_section_xy(sec)
% Use RANSAC on a section's xy matches to improve total alignment
%
% Inputs:
%   sec: section struct with xy_matches
%
% Outputs:
%   alignment: alignment struct (i.e. sec.alignments.xy)
%
% alignment = ransac_section_xy(sec)

params.iterations = 1000;
params.min_inliers = 3;
params.point_threshold = 5;
params.fixed_tile = 1; % could vary fixed_tile...

best_alignment = sec.alignments.xy;
best_error = alignment.meta.avg_post_error;

for i = 1:params.iterations
    % Select random inlier set of matches
    for j = 1:sec.num_tiles
        % Cycle through tiles and select min_inliers
    end
    % Create set of possible tforms from random inliers
    [tforms, ~, avg_error] = sp_lsq(random_inliers, params.fixed_tile);
    
    % Apply possible tforms to remaining matches and collect also inliers
    for j = 1:sec.num_tiles
        % Cycle through tiles and keep matches below point_threshold
    end
    
    % Determine if also inliers are sufficient - maybe a certain fraction
    if also_inliers > mediocre
        [new_tforms, ~, new_avg_error] = sp_lsq(random_inliers + also_inliers, params.fixed_tile);
        
        if new_avg_error < best_error;
            best_alignment = new_tforms;
            best_error = new_avg_error;
        end
    end
end

