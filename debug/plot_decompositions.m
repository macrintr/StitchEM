function stats = plot_decompositions(secs, tile)
% Build plot tracking affine decomposition components
%
% Inputs
%   secs: cell array of section structs
%
% Outputs
%   stats: struct collecting decomposition components for each section
%
% stats = plot_decompositions(secs)

if nargin < 2
    tile = 6;
end

stats = dataset();

for s = 1:length(secs)
    d = decompose_affine_matrix(secs{s}.alignments.z.tforms{tile}.T);
    ds = struct2dataset(d);
    ds.no = s;
    ds.tile = tile;
    stats = [stats; ds];
end

name = sprintf('Affine decompositions, Sec%d-%d, tile %d', 1, length(secs), tile);
fig = figure('name', name);
tb = uicontrol('style','text');
set(tb, 'String', 'x * M = x * Sc * Sh * R + t');
set(tb, 'Position', [0 0 200 50]);
set(tb,'Units','characters');
title(name);

subplot(4, 1, 1);
plot(stats.scale_x);
hold on
plot(stats.scale_y);
title('scale (Sc)');
legend('scale_x', 'scale_y', 'Location', 'best');
ylabel('factor');
grid on

subplot(4, 1, 2);
plot(stats.shear);
title('shear (Sh)');
ylabel('factor');
grid on

subplot(4, 1, 3);
plot(stats.theta);
title('rotation (R)');
ylabel('radians');
grid on

subplot(4, 1, 4);
plot(stats.t_x);
hold on
plot(stats.t_y);
title('translation (t)');
legend('t_x', 't_y', 'Location', 'best');
ylabel('distance (px)');
xlabel('section no');
grid on
