function sec = select_xy_matches(sec, tileA_num, tileB_num)
% Select xy_matches using cpselect for two tiles

% Inputs:
%   tileA: image of fixed tile
%   tileB: image of moving tile
%
% Outputs:
%   sec: updated section struct with modified xy_matches attribute

% Load images
tile_paths = get_tile_paths(sec, waferpath);
tileA = imread(tile_paths{tileA_num});
tileB = imread(tile_paths{tileB_num});

% Load existing matches (takes a lot of time, usually)
% filter = sec.xy_matches.A.tile == tileA_num & sec.xy_matches.B.tile == tileB_num;
% matchesA = sec.xy_matches.A(filter, :).local_points;
% matchesB = sec.xy_matches.B(filter, :).local_points;
% 
% [ptsA, ptsB] = cpselect(tileA, tileB, matchesA, matchesB, 'Wait', true);

[ptsA, ptsB] = cpselect(tileA, tileB, 'Wait', true);

manual_xy_matches.A = table();
manual_xy_matches.B = table();
manual_xy_matches.A.local_points = ptsA;
manual_xy_matches.B.local_points = ptsB;

% Get global positions of features
tforms = sec.alignments.rough_xy.tforms;
manual_xy_matches.A.global_points = tforms{tileA_num}.transformPointsForward(ptsA);
manual_xy_matches.B.global_points = tforms{tileB_num}.transformPointsForward(ptsB);

manual_xy_matches.A.tile = tileA_num * ones(length(ptsA), 1);
manual_xy_matches.B.tile = tileB_num * ones(length(ptsA), 1);

if ~isfield(sec.xy_matches, 'manual')
    sec.xy_matches.manual.A = table();
    sec.xy_matches.manual.B = table();
end

sec.xy_matches.manual.A = [sec.xy_matches.manual.A; manual_xy_matches.A];
sec.xy_matches.manual.B = [sec.xy_matches.manual.B; manual_xy_matches.B];
sec.xy_matches.manual.num_matches = height(sec.xy_matches.manual.A);
sec.xy_matches.modified = 'select_xy_matches';

sec.xy_matches.A = [sec.xy_matches.A; manual_xy_matches.A];
sec.xy_matches.B = [sec.xy_matches.B; manual_xy_matches.B];
sec.xy_matches.num_matches = height(sec.xy_matches.A);

plot_rough_xy(sec), plot_matches(sec.xy_matches)

% sec.alignments.xy = align_xy(sec);
% [section, section_R] = render_section(sec, 'xy', 'scale', 0.08);
% imshow(section)
