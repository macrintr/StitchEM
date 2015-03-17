function secs = characterize_jitter(secs, num_of_secs)
% Run all sec structs through blockcorr_matches for jitter matches

if nargin < 2
    num_of_secs = length(secs);
end

% secs{1}.tile_sizes = secs{1}.tile_sizes';
for i=2:num_of_secs
%     secs{i}.tile_sizes = secs{i}.tile_sizes';
    
    secs{i}.blockcorr_matches = match_blockcorr(secs{i-1}, secs{i});
    secs{i}.blockcorr_matches.outliers.A = [];
    secs{i}.blockcorr_matches.outliers.B = [];

    stats = plot_blockcorr_matches_stats(secs, i);
    a = stats(stats.dist > 30, :);
    id_list = a.id;
    secs{i}.blockcorr_matches = remove_matches_by_id(secs{i}.blockcorr_matches, id_list);
end


