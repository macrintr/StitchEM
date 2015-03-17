%% Setup
clearvars;
clc;
W001;

% params(1).xy.skip_tiles = [3:16];
% params(2).xy.skip_tiles = [3:16];

start = 1;
finish = 2;

%% Auto align XY
align_stack_xy;

%% Manual XY inspection
%% Sec1
plot_rough_xy(secs{1}), plot_matches(secs{1}.xy_matches), plot_matches(secs{1}.xy_matches.outliers.A, secs{1}.xy_matches.outliers.A, 1.0, true)

stats = plot_xy_matches_stats(secs{1});
m = stats;
[s, i] = sort(m.dist, 'descend');
id_list = m.id(i);

mov = imshow_matches(secs{1}, secs{1}, m(i, :), 'xy', 1.0);

% Remove outliers
% Save secs

%% Sec2
plot_rough_xy(secs{2}), plot_matches(secs{2}.xy_matches), plot_matches(secs{2}.xy_matches.outliers.A, secs{2}.xy_matches.outliers.A, 1.0, true)

stats = plot_xy_matches_stats(secs{2});
m = stats;
[s, i] = sort(m.dist, 'descend');
id_list = m.id(i);

mov = imshow_matches(secs{2}, secs{2}, m(i, :), 'xy', 1.0);

% Remove outliers
% Save secs

%% Auto Z align
params(2).z.scale = 0.5;
params(2).z.features.scale = 0.5;
params(2).z.alignment_method = 'lsq';

% rough_align_z;
align_stack_z;

%% Manual Z inspection
plot_z_matches_global(secs{1}, secs{2})

stats = plot_z_matches_stats(secs, 2);
m = stats;
[s, i] = sort(m.dist, 'descend');
id_list = m.id(i);

mov = imshow_matches(secs{1}, secs{2}, m(i, :), 0.5);

% Remove outliers
% Save secs

%% Render the sections
% render_wafers;