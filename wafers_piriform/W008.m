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

% Custom per-section parameters
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

% Shift the cropping window of the overview in rough_xy alignment
for s=1:length(sec_nums); params(s).xy.rough.overview_registration.overview_cropping = [0.3300 0.1600 0.5700 0.5700]; end

% params(31).xy.skip_tiles = [14];
% params(32).xy.skip_tiles = [14];
% params(33).xy.skip_tiles = [14];
% params(40).xy.skip_tiles = [14];
% params(44).xy.skip_tiles = [14];
% params(45).xy.skip_tiles = [9];
% params(47).xy.skip_tiles = [14];
% params(64).xy.skip_tiles = [14];
% params(66).xy.skip_tiles = [3];
% params(78).xy.skip_tiles = [3];
% params(80).xy.skip_tiles = [16];
% params(82).xy.skip_tiles = [11];
% params(88).xy.skip_tiles = [3];
% params(89).xy.skip_tiles = [3];
% params(90).xy.skip_tiles = [3];
% params(97).xy.skip_tiles = [3];
% params(102).xy.skip_tiles = [3];
% params(121).xy.skip_tiles = [3];
% params(125).xy.skip_tiles = [1 6];
% params(145).xy.skip_tiles = [2];
% params(148).xy.skip_tiles = [14];
% params(155).xy.skip_tiles = [2 3];
% params(156).xy.skip_tiles = [3];
% params(158).xy.skip_tiles = [3];
% params(166).xy.skip_tiles = [3];
% params(169).xy.skip_tiles = [3];

% Fix W008 Sec3 (rough_xy failure - tile 15; nothing obvious - maybe lack of large features)
% Fix W008 Sec14 (no features found in tiles - all tiles blurry from movement; skipping)
% Fix W008 Sec31 (tile 14 no matches - blurry)
% Fix W008 Sec32 (tile 14 no matches - blurry)
% Fix W008 Sec33 (tile 14 no matches - blurry)
% Fix W008 Sec35 (rough_xy failure - many; overview is blurry)
% Fix W008 Sec40 (tile 14 no matches - blurry)
% Fix W008 Sec44 (tile 14 no matches - blurry)
% Fix W008 Sec45 (tile 9 is white)
% Fix W008 Sec47 (tile 14 no matches - blurry)
% Fix W008 Sec54 (rough_xy failure - tile 11, 16; nothing obvious - too light & lack of large features?)
% Fix W008 Sec64 (tile 14 no matches - blurry)
% Fix W008 Sec66 (tile 3 rough xy fail - blurry)
% Fix W008 Sec68 (rough_xy failure - all; overview is blurry)
% Fix W008 Sec69 (rough_xy failure - all; overview is blurry)
% Fix W008 Sec78 (rough_xy failure - tile 15; nothing obvious - lack of large features?)
% Fix W008 Sec80 (tile 16 is white)
% Fix W008 Sec82 (tile 10 is white)
% Fix W008 Sec88 (tile 3 no matches - blurry)
% Fix W008 Sec89 (tile 3 no matches - blurry)
% Fix W008 Sec90 (tile 3 no matches - blurry)
% Fix W008 Sec93 (bad match somewhere)
% Fix W008 Sec96 (rough_xy failure - many; overview is blurry?)
% Fix W008 Sec97 (tile 3 no matches - blurry)
% Fix W008 Sec101 (rough_xy failure - many; overview is blurry?)
% Fix W008 Sec102 (tile 3 no matches - blurry)
% Fix W008 Sec121 (tile 3 no matches - blurry)
% Fix W008 Sec125 (tile 1, 6 no matches - blurry)
% Fix W008 Sec143 (rough_xy failure - all; overview is blurry?)
% Fix W008 Sec145 (tile 2 is white)
% Fix W008 Sec148 (tile 14 no matches - blurry)
% Fix W008 Sec155 (tile 2 is white, tile 3 is blurry)
% Fix W008 Sec156 (tile 3 rough_xy - blurry)
% Fix W008 Sec158 (tile 3 no matches - blurry)
% Fix W008 Sec166 (tile 3 no matches - blurry)
% Fix W008 Sec169 (tile 3 no matches - blurry)