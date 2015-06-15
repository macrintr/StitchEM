%% Configuration

% renderpath
renderpath('/usr/people/tmacrina/seungmount/research/tommy/150502_piriform/affine_reviews/');

% Wafer and sections
waferpath('/usr/people/tmacrina/seungmount/research/GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-W005/HighResImages_ROI1_W005_7nm_120apa')
info = get_path_info(waferpath);
wafer = info.wafer;
sec_nums = info.sec_nums;

% Load default parameters
default_params

%% Custom per-section parameters
% Note: The index of params corresponds to the actual section number.
% 
% Example:
%   => Change the NNR MaxRatio of section 38:
%   params(38).z.NNR.MaxRatio = 0.8;
%
%   => Set the max match error for sections 10 to 15 to 2000:
%   params(10).z.max_match_error = 2000; % change section 10's parameters
%   [params(11:15).z] = deal(params(10).z); % copy it to sections 11-15
%       Or:
%   for s=10:15; params(s).z.max_match_error = 2000; end

params(27).xy.skip_tiles = [15];
params(47).xy.skip_tiles = [4];

% Shift the cropping window of the overview in rough_xy alignment
for s=51:length(sec_nums); params(s).xy.rough.overview_registration.overview_cropping = [0.3300 0.1600 0.5700 0.5700]; end
params(51).xy.skip_tiles = [5];
params(66).xy.skip_tiles = [13];
params(68).xy.skip_tiles = [13];
params(117).xy.skip_tiles = [16];

params(50).z.matching_mode = 'manual';
params(51).z.matching_mode = 'manual';

% Fix W007 Sec51 (tile 5 is white)
% Fix W007 Sec55 (rough_xy failure - tile 1 & 14; nothing obvious)
% Fix W007 Sec66 (tile 13 no matches - blurry)
% Fix W007 Sec68 (tile 13 no matches - blurry)
% Fix W007 Sec70 (tile 1 no matches - small overlap)
% Fix W007 Sec117 (tile 16 is white)