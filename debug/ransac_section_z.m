function sec = ransac_section_z(secs, s)
% Use RANSAC on a section's z matches to improve total alignment
%
% Inputs:
%   sec: section struct with z_matches
%
% Outputs:
%   matches: matches struct (i.e. sec.z_matches)
%
% alignment = ransac_section_z(sec)


% plot_z_matches_global(secs{s-1}, secs{s});
% imshow_z_residuals(secs, s);

params.iterations = 100;
params.min_inliers = 5;
params.point_threshold = 50;
params.acceptable_fraction_of_original_matches = 0.80;

original_matches = secs{s}.z_matches;
best_matches = original_matches;
num_matches = height(original_matches.A);
best_alignment = secs{s}.alignments.z;
moving_tforms = secs{s}.alignments.z.tforms;
fixed_tforms = secs{s-1}.alignments.z.tforms;

storage = cell(1, params.iterations);

stats = calculate_matches_stats(original_matches, fixed_tforms, moving_tforms);
best_error = max(stats.dist);
fprintf('Best error <strong>%f</strong> with <strong>%d</strong> matches\n', best_error, height(best_matches.A));

parfor i = 1:params.iterations
    fprintf('RANSAC Iteration %d/%d\n', i, params.iterations);
    % Select random inlier set of matches
    jumbled_indices = randperm(num_matches);
    rand_ids = jumbled_indices(1:params.min_inliers);
    [possible_inliers, rand_inliers] = remove_matches_by_id(original_matches, rand_ids);

    % Create set of possible tforms from random inliers
    possible_alignment = align_z_pair_lsq(secs{s}, rand_inliers, 'prev_z');
    possible_tforms = possible_alignment.tforms;
    
    % Apply possible tforms to remaining matches and collect also inliers
    stats = calculate_matches_stats(possible_inliers, fixed_tforms, possible_tforms);
    outlier_ids = stats.id(stats.dist > params.point_threshold);
    [also_inliers, outliers] = remove_matches_by_id(possible_inliers, outlier_ids);
    
    inliers = also_inliers;
    inliers.A = [inliers.A; rand_inliers.A];
    inliers.B = [inliers.B; rand_inliers.B];
    inliers.num_matches = height(inliers.A);
    
    % Are also inliers sufficient (certain fraction of original, for now)
    if height(also_inliers.A) > params.acceptable_fraction_of_original_matches * num_matches
        new_alignment = align_z_pair_lsq(secs{s}, inliers, 'prev_z');
        new_tforms = new_alignment.tforms;
        stats = calculate_matches_stats(inliers, fixed_tforms, new_tforms);
        new_error = max(stats.dist);
        
        storage{i}.new_alignment = new_alignment;
        storage{i}.new_error = new_error;
        storage{i}.new_matches = inliers;
        
%         if new_error < best_error;
%             best_error = new_error;
%             best_matches = inliers;
%             best_alignment = new_alignment;
%             fprintf('Best error <strong>%f</strong> with <strong>%d</strong> matches\n', best_error, height(best_matches.A));
%         end
%     end
    else
        storage{i}.new_alignment = best_alignment;
        storage{i}.new_error = best_error;
        storage{i}.new_matches = best_matches;
    end
end

for i = 1:length(storage)
    new_error = storage{i}.new_error;
    new_alignment = storage{i}.new_alignment;
    inliers = storage{i}.new_matches;
    
    if new_error < best_error;
        best_error = new_error;
        best_matches = inliers;
        best_alignment = new_alignment;
        fprintf('Best error <strong>%f</strong> with <strong>%d</strong> matches\n', best_error, height(best_matches.A));
    end
end

sec = secs{s};
sec.z_matches = best_matches;
sec.z_matches.meta.ransac = params;
sec.z_matches.meta.ransac.date = datestr(now);
sec.alignments.z = best_alignment;

% plot_z_matches_global(secs{s-1}, sec);
% imshow_z_residuals({secs{s-1}, sec}, 2);
