function imshow_overview_pair(secA, secB, aA, aB)
% Show overviews merged together (alignments optional)
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

[merge, m_R] = render_overview_pair(secA, secB, aA, aB);
figure();
imshow(merge, m_R);