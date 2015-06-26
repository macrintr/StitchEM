function D = decompose_affine_matrix(M)
% Decompose affine into scale, shear, rotation, & translation components
%
% Inputs
%   M: affine matrix (3x3)
%
% Outputs
%   decomposition: struct with attributes scalex, scaley, angle, tx, & ty
%
% Decomposition is not unique, but should be consistent for comparisons.
% Pulling first decomposition from http://math.stackexchange.com/questions/78137/decomposition-of-a-nonsquare-affine-matrix
%   A = (Scale * Shear * Rotation)*x + Translation

a = M(1,1);
b = M(1,2);
c = M(2,1);
d = M(2,2);
theta = atan2(b, a);

D.t_x = M(3,1);
D.t_y = M(3,2);

D.theta = theta;
D.scale_x = (a^2 + b^2)^(1/2);
D.scale_y = (a*d - b*c) / (D.scale_x);
D.shear = (a*c + b*d) / (a*d - b*c);

Sc = [D.scale_x 0 0; 0 D.scale_y 0; 0 0 1];
Sh = [1 0 0; D.shear 1 0; 0 0 1];
R = [cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0; 0 0 1];
t = [0 0 0; 0 0 0; D.t_x D.t_y 0];

L = Sc * Sh * R;
L = L(1:2, 1:2);
K = M(1:2, 1:2);
assert(~sum(sum(L - K > 0.000001)));

% theta = atan2(d, a);
% D.theta = theta;
% D.scale_x = (a^2 + c^2)^(1/2);
% D.scale_y = d*cos(theta) - b*sin(theta);
% D.shear = (b*cos(theta) + d*sin(theta)) / (d*cos(theta) - b*sin(theta));