function secsB = insert_space_for_section(secs, s)
% Make room in cell array for new section
%
% Inputs
%   secs: cell array of section structs
%   s: index of new section struct space
%
% Output
%   secsB: updated cell array (length + 1)
%
% secs = insert_space_for_section(secs, s)

secsB = cell(1, length(secs) + 1);
for i = 1:length(secsB)
    if i < s
        secsB{i} = secs{i};
    elseif i == s
        secsB{i} = [];
    else
        secsB{i} = secs{i-1};
    end
end