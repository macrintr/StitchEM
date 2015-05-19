function imwrite_overview_pair(secA, secB, aA, aB, dir)
% Write render_overview_pair with tforms to given directory
%
% Inputs:
%   secA: first overview section
%   secB: second overview section
%   aA: string for section A overview alignment
%   aB: string for section B overview alignment
%   dir: string for renderpath directory

[merge, merge_spatial_ref] = render_overview_pair(secA, secB, aA, aB);
imwrite(merge, fullpath(renderpath.(dir), [secB.name '.tif']))
fprintf('<strong>Writing</strong> %s for %s to renderpath\n', dir, secB.name)
