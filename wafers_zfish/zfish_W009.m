%% Configuavtionv

% renderpath
renderpath('/mnt/bucket/labs/seung/research/dodam/150528_zfish/affine_reviews/');

% Wafer and sections
waferpath('/mnt/bucket/labs/seung/research/GABA/data/atlas/MasterUTSLdirectory/10122012-1/W009/HighResImages_Fine_5nm_120apa_W009/')
info = get_path_info(waferpath);
wafer = info.wafer;
sec_nums = info.sec_nums;
%sec_nums(122) = []; % skip

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
%   params(10).z.max_match_error = 2000; % change section 10zzzzzzzzzzz's parameters
%   [params(11:15).z] = deal(params(10).z); % copy it to sections 11-15
%       Or:
%   for s=10:15; params(s).z.max_match_error = 2000; end

% S2-W001

% params(54).xy.skip_tiles = [1];
% params(56).xy.skip_tiles = [1];
%paams(27).xy.skip_tiles = [15, 16];