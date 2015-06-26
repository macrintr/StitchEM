function z_matches = select_z_matches(secA, secB, alignmentA, alignmentB)
% Manually select Z matches.
%
% Inputs
%   secA: fixed section struct
%   secB: moving section struct
%   alignmentA: alignment to apply to secA
%   alignmentB: alignment to apply to secB
%
% Output
%   z_matches: matches struct

if nargin < 3
    alignmentA = 'z';
    alignmentB = 'xy';  
end

scale = 0.025;

[A, R_A] = render_section(secA, alignmentA, 'scale', scale);
[B, R_B] = render_section(secB, alignmentB, 'scale', scale);

[ptsB, ptsA] = cpselect(B, A, 'Wait', true);

offsetA = [R_A.XWorldLimits(1), R_A.YWorldLimits(1)];
offsetB = [R_B.XWorldLimits(1), R_B.YWorldLimits(1)];

ptsA = ptsA / scale;
ptsB = ptsB / scale;

ptsA = bsxadd(ptsA, offsetA);
ptsB = bsxadd(ptsB, offsetB);

z_matches.A = table();
z_matches.B = table();
z_matches.A.global_points = ptsA;
z_matches.B.global_points = ptsB;

z_matches.num_matches = height(z_matches.A);
z_matches.secA = secA.name;
z_matches.secB = secB.name;
z_matches.alignmentA = alignmentA;
z_matches.alignmentB = alignmentB;
z_matches.match_type = 'z';
z_matches.meta.method = 'select_z_matches';
z_matches.meta.scale = scale;
z_matches.meta.scaled_offsetA = offsetA;
z_matches.meta.scaled_offsetB = offsetB;
z_matches.meta.avg_error = rownorm2(z_matches.B.global_points - z_matches.A.global_points);

z_matches = transform_global_matches(z_matches, secA, secB, alignmentA, alignmentB);

end

