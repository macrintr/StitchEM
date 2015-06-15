function sec_nums = find_wafer_in_secs(secs, wafer)
% Pull array of cell locations associated with a given wafer number
%
% Inputs:
%   secs: cell array of section structs
%   wafer: string of the wafer desired
%
% Outputs:
%   sec_nums: array of indices where desired wafer sections are in secs
%
% sec_nums = find_wafer(secs, wafer_num)

sec_nums = [];
for i = 1:length(secs)
    if strcmp(secs{i}.wafer, wafer)
        sec_nums(end+1) = i;
    end
end