function imwrite_section_pair(secA, secB, aA, aB, dir)
% Write render_section_pair with tforms to given directory
%
% Inputs:
%   secA: first section
%   secB: second section
%   aA: string for section A alignment
%   aB: string for section B alignment
%   dir: string for renderpath directory
%
% imwrite_overview_pair(secA, secB, aA, aB, dir)

[merge, merge_spatial_ref] = render_section_pair(secA, secB, aA, aB);
merge = imresize(merge, 0.5);
path = renderpath();
imwrite(merge, fullfile(path.(dir), [secB.name '_' secA.name '_z_render.tif']));
fprintf('<strong>Writing</strong> %s for %s on %s to renderpath\n', dir, secB.name, secA.name);
close;
