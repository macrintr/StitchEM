function [merge, m_R] = render_section_pair(secA, secB, aA, aB)
% Render stitched sections and merge together (alignments optional)
%
% Inputs:
%   secA: section struct
%   secB: section struct
%   aA: string for section A alignment (i.e. 'z')
%   aB: string for section B alignment (i.e. 'z')

if nargin == 2
    aA = 'z'; 
    aB = 'z';
elseif nargin == 3
    aB = aA;
end

tformsA = secA.alignments.(aA).tforms;
[sA sA_R] = render_section(secA, tformsA, 'scale', 0.05);

tformsB = secB.alignments.(aB).tforms;
[sB sB_R] = render_section(secB, tformsB, 'scale', 0.05);

[merge, m_R] = imfuse(sA, sA_R, sB, sB_R);
figure();
imshow(merge, m_R);