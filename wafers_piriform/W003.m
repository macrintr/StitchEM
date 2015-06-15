%% Configuration

% renderpath
renderpath('/usr/people/tmacrina/seungmount/research/tommy/150502_piriform/affine_reviews/');

% Wafer and sections
waferpath('/usr/people/tmacrina/seungmount/research/GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-W003/HighResImages_ROI1_7nm_120apa')
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

% % S2-W003:
% %Section 72 is rotated by quite a bit, but 73 goes back to normal
% params(72).z = z_presets.large_trans;
% params(73).z = z_presets.rel_to_2previous;
% params(140).z = z_presets.ignore_z_error;
% params(141).z = z_presets.rel_to_2previous;

%% Run alignment
% try
%     align_stack_xy
%     align_stack_z
% catch alignment_error
%     troubleshoot
% end