function matches = remove_matches_by_id(matches, id_list)
% Remove all the match pairs with an id in the id_list
%
% Input:
%   matches: matches struct, like sec.xy_matches or sec.z_matches
%   id_list: vector of ids corresponding to match pairs to be removed
%
% Output:
%   matches: same matches struct, to be reassinged to sec.xy_mathces or
%   sec.z_matches.

% Sort the id_list in descending order, so that our removals won't disrupt
% the indices of the next pairs to remove.
id_list = sort(id_list,'descend');

for i=id_list
    matches.A(i, :) = [];
    matches.B(i, :) = [];
end
