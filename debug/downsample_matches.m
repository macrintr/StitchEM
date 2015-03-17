function id_list = downsample_matches(stats, percent)
% Remove inputted percentage of matches from each tile pair
%
% Input:
%   stats: joined dataset of matches
%   percent: number for percentage of matches to remove
%
% Output:
%   id_list: vector of match ids to be removed
%
% This method is to make an excessively large number of matches more 
% manageable for visual inspection.

tile_pairs = unique([stats.tileA stats.tileB], 'rows');
id_list = [];
for i=1:length(tile_pairs)
    stats_segment = stats(stats.tileA == tile_pairs(i, 1) & stats.tileB == tile_pairs(i, 2), :);
    if length(stats_segment) > 25 % limit will cap this to 25
        mask = rand(length(stats_segment), 1) < percent;
        if sum(mask) > 3 % need at least 3
            id_list = [id_list; stats_segment.id(mask)];
        end
    end
end
    