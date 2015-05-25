function [merge, m_R] = render_overview_pair(secA, secB, aA, aB)
% Render overviews and merge together (alignments optional)
%
% Inputs:
%   secA: section struct
%   secB: section struct
%   aA: string for section A alignment (i.e. 'z')
%   aB: string for section B alignment (i.e. 'z')

if nargin == 2
    aA = 'initial'; 
    aB = 'rough_z';
elseif nargin == 3
    aB = aA;
end

if isempty(secB.overview.img)
	secB = load_overview(secB);
end
if isempty(secA.overview.img)
	secA = load_overview(secA);
end

tformA = secA.overview.alignments.(aA).tform;
[sA sA_R] = imwarp(secA.overview.img, tformA);

tformB = secB.overview.alignments.(aB).tform;
[sB sB_R] = imwarp(secB.overview.img, tformB);

[merge, m_R] = imfuse(sA, sA_R, sB, sB_R);
figure();
imshow(merge, m_R);