%% Configuration
% Wafer and sections
waferpath('/usr/people/tmacrina/seungmount/research/GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-W001/HighResImages_ROI1_7nm_120apa/')
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

% S2-W001

params(54).xy.skip_tiles = [1];
params(56).xy.skip_tiles = [1];