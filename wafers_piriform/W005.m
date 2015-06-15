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

% S2-W005
% XY
% params(35).xy = xy_presets.grid_align;
% params(56).xy.max_match_error = inf;
% 
% % Z
% params(4).z.max_match_error = inf;
% params(5).z.max_match_error = inf;
% params(8).z.max_match_error = inf;
% params(9).z.max_match_error = inf;
% params(10).z.max_match_error = inf;
% params(11).z.max_match_error = inf;
% params(15).z.max_match_error = inf;
% params(20).z.max_match_error = inf;
% params(21).z.max_match_error = inf;
% params(25).z.max_match_error = inf;
% params(26).z.max_match_error = inf;
% params(27).z.max_match_error = inf;
% params(28).z.max_match_error = inf;
% params(29).z.max_match_error = inf;
% params(32).z.max_match_error = inf;
% for s=33:length(params); params(s).z.max_match_error = inf; end

%% Run alignment
% try
%     align_stack_xy
%     align_stack_z
% catch alignment_error
%     troubleshoot
% end