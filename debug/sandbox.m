% T Macrina
% 141022
% Use this file to try investigate Talmo's code
%
% Milestones:
%  align & stitch two tiles together
%  display the two tiles with correspondence points
%  modify the correspondence points in a GUI
% 

% Prepare the MATLAB environment
Initialize_StitchEM

% Ripped from W001.m
%
waferpath('/mnt/data0/ashwin/stitch_trial')
info = get_path_info(waferpath);
wafer = info.wafer;
sec_nums = info.sec_nums;

% Load default parameters
default_params

% Ripped from pipeline/align_stack_xy, line 1
%
% Rough & XY Alignment
if ~exist('params', 'var'); error('The ''params'' variable does not exist. Load parameters before doing alignment.'); end
if ~exist('secs', 'var'); secs = cell(length(sec_nums), 1); end
if ~exist('status', 'var'); status = struct(); end
if ~isfield(status, 'step'); status.step = 'xy'; end
if ~isfield(status, 'section'); status.section = 1; end
if ~strcmp(status.step, 'xy'); disp('<strong>Skipping XY alignment.</strong> Clear ''status'' to reset.'), return; end

% Ripped from pipeline/align_stack_xy, line 15
%
% Using s =5 is me breaking the for loop just to see how this works
s = 5;
status.section = s;
sec_timer = tic;

% Parameters
xy_params = params(sec_nums(s)).xy;
fprintf('=== Aligning %s (<strong>%d/%d</strong>) in XY\n', get_path_info(get_section_path(sec_nums(s)), 'name'), s, length(sec_nums))

% Check for overwrite
if ~isempty(secs{s}) && isfield(secs{s}.alignments, 'xy')
if xy_params.overwrite; warning('XY:AlignedSecOverwritten', 'Section is already aligned, but will be overwritten.')
else error('XY:AlignedSecNotOverwritten', 'Section is already aligned.'); end
end
% Section structure
if ~exist('sec', 'var') || sec.num ~= sec_nums(s)
% Create a new section structure
sec = load_section(sec_nums(s), 'skip_tiles', xy_params.skip_tiles, 'wafer_path', waferpath());
else
% Use section in the workspace
disp('Using section that was already loaded. Clear ''sec'' to force section to be reloaded.')
end
% Load images
if ~isfield(sec.tiles, 'full'); sec = load_tileset(sec, 'full', 1.0); end
if ~isfield(sec.tiles, 'rough'); sec = load_tileset(sec, 'rough', xy_params.rough.overview_registration.tile_scale); end
if isempty(sec.overview) || ~isfield(sec.overview, 'img') || isempty(sec.overview.img) ...
|| ~isfield(sec.overview, 'scale') || sec.overview.scale ~= xy_params.rough.overview_registration.overview_scale
sec = load_overview(sec, xy_params.rough.overview_registration.overview_scale);
end

% Rough alignment
sec.alignments.rough_xy = rough_align_xy(sec, xy_params.rough);
% Detect XY features
sec.features.xy = detect_features(sec, 'alignment', 'rough_xy', 'regions', 'xy', xy_params.features);
% Match XY features
sec.xy_matches = match_xy(sec, 'xy', xy_params.matching);

% Check for bad matching
if sec.xy_matches.meta.avg_error > xy_params.max_match_error
msg = sprintf('[%s]: Error after matching is very large. This may be due to bad rough alignment or match filtering.', sec.name);
id = 'XY:LargeMatchError';
if xy_params.ignore_error; warning(id, msg); else error(id, msg); end
elseif ~isempty(find_orphan_tiles(sec, 'xy'))
msg = sprintf('[%s]: There are tiles with no matches to any other tiles.\n\tOrphan tiles: %s\n', sec.name, vec2str(find_orphan_tiles(sec, 'xy')));
id = 'XY:OrphanTiles';
if xy_params.ignore_error; warning(id, msg); else error(id, msg); end
end

% Align XY
sec.alignments.xy = align_xy(sec, xy_params.align);

% Check for bad alignment
if sec.alignments.xy.meta.avg_post_error > xy_params.max_aligned_error
msg = sprintf('[%s]: Error after alignment is very large. This may be due to bad matching.', sec.name);
id = 'XY:LargeAlignmentError';
if xy_params.ignore_error; warning(id, msg); else error(id, msg); end
end

 % Save
sec.params.xy = xy_params;
sec.runtime.xy.time_elapsed = toc(sec_timer);
sec.runtime.xy.timestamp = datestr(now);

yellow = uint8([255 255 0]);
green = uint8([0 255 0]);
red = uint8([255 0 0]);

vars = 'local_points';
radius = 80;
secs_circles = [];
lines = [];

for n = 1:sec.num_tiles
 tile = sec.tiles.full.img{n}; 
 tile_rgb = repmat(tile, [1,1,3]); % convert tile to RGB
 color = yellow;

 A_rows = sec.xy_matches.A.tile==n;
 A_coords = sec.xy_matches.A(A_rows, vars).local_points;
 A_num = size(A_coords, 1);
 A_circles = int32([A_coords ones(A_num, 1)*radius]);
 A_shapeInserter = vision.ShapeInserter('Shape', 'Circles', 'BorderColor', 'Custom', 'CustomBorderColor', yellow);

 B_rows = sec.xy_matches.B.tile==n;
 B_coords = sec.xy_matches.B(B_rows, vars).local_points;
 B_num = size(B_coords, 1);
 B_circles = int32([B_coords ones(B_num, 1)*radius]);
 B_shapeInserter = vision.ShapeInserter('Shape', 'Circles', 'BorderColor', 'Custom', 'CustomBorderColor', green);
 
 tile_circles = step(A_shapeInserter, tile_rgb, A_circles);
 tile_circles = step(B_shapeInserter, tile_circles, B_circles);
 
 lines = [lines; A_coords B_coords];
end



A_filename = 'Tile_r2-c2_S2-W001_sec5_CIRLCES.tif';
% imwrite(A_drawn, fullfile(cachepath, A_filename));


B_filename = 'Tile_r2-c3_S2-W001_sec5_CIRLCES.tif';
% imwrite(B_drawn, fullfile(cachepath, B_filename));

BOTH_drawn = [A_drawn B_drawn];
BOTH_filename = 'Tiles_r2-c2_r2-c3_S2-W001_sec5_CIRCLES.tif';
% imwrite(BOTH_drawn, fullfile(cachepath, BOTH_filename));

% imshow(A_drawn)
