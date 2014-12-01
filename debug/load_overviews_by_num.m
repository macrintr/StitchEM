function [secs] = load_overviews_by_num(secs, n)
% Load overviews to the sections listed in n
% Inputs:
%       secs: sections structure for one wafer (i.e. W001)
%       n: array of numbers for section ids
% Output:
%       secs: revised sections structure with loaded overviews

for i=n
    sec = secs{i};
    secs{i} = load_overview(sec, sec.overview.scale);
end