function imshow_section_pair(secA, secB, aA, aB)
% Show stitched sections merged together (alignments optional)
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

[merge, m_R] = render_section_pair(secA, secB, aA, aB);
figure();
imshow(merge, m_R);