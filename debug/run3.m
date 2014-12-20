% clc;
% clearvars;
% load('results/S2-W004_rough_z_aligned.mat');
% clear('status');
% waferpath('/mnt/data0/ashwin/07122012/S2-W004')
% info = get_path_info(waferpath);
% wafer = info.wafer;
% sec_nums = info.sec_nums;
% % Load default parameters
% default_params
% start = 1;
% finish = 31;
% align_stack_z;
% secs{31} = propagate_z_for_missing_tiles(secs{30}, secs{31});
% clear('status');
% start = 32;
% finish = 139;
% align_stack_z;
% secs{139} = propagate_z_for_missing_tiles(secs{138}, secs{139});
% clear('status');
% start = 140;
% finish = size(secs, 1);
% align_stack_z;
% 
% waferA = '/home/tmacrina/StitchEM/results/S2-W002_z_aligned.mat';
% waferB = '/home/tmacrina/StitchEM/results/S2-W003_z_aligned.mat';
% align_wafers;
% waferA = '/home/tmacrina/StitchEM/results/S2-W003_z_aligned.mat';
% waferB = '/home/tmacrina/StitchEM/results/S2-W004_z_aligned.mat';
% align_wafers;
% waferA = '/home/tmacrina/StitchEM/results/S2-W004_z_aligned.mat';
% waferB = '/home/tmacrina/StitchEM/results/S2-W005_z_aligned.mat';
% align_wafers;

% NEED TO SAVE WITHIN ALIGN_WAFERS - COULD DO ALL WAFERS AT ONCE

% clc;
% clearvars;
% try
%     W007;
% catch
%     filename = sprintf('cache/%s_xy_aligned.mat', secs{1}.wafer);
%     save(filename, 'secs', '-v7.3');
% end
% 
% try
%     render_secs(secs, 0.08);
% catch
% end

% try
%     waferpath('/mnt/data0/ashwin/07122012/S2-W008')
%     
%     % Analyze path
%     info = get_path_info(waferpath);
%     status.wafer = info.wafer;
%     status.pipeline_script = mfilename;
%     sec_nums = info.sec_nums;
%     
%     % Skip sections
%     %sec_nums(103) = []; % skip
%     
%     % Load default parameters
%     default_params
%     align_stack_xy;
% catch
%     filename = sprintf('cache/%s_xy_aligned.mat', secs{1}.wafer);
%     save(filename, 'secs', '-v7.3');
% end
% 
% try
%     render_secs(secs, 0.08);
% catch
% end

% try
%     render_secs(secs, 0.08);
% catch
% end

% clearvars;
% 
% waferpath('/mnt/data0/ashwin/07122012/S2-W007')
% % Analyze path
% info = get_path_info(waferpath);
% status.wafer = info.wafer;
% status.pipeline_script = mfilename;
% sec_nums = info.sec_nums;
% % Load default parameters
% default_params;
% align_stack_xy;
% load('S2-W007_Sec7_xy_aligned.mat')
% secs{7} = sec;
% 
% filename = sprintf('%s_xy_aligned.mat', secs{1}.wafer);
% save(filename, 'secs', 'error_log', '-v7.3');
% try
%     render_secs(secs, 0.02);
% catch
% end
% 
% render_secs(secs, 0.02);
% 
% clearvars;
% 
% waferpath('/mnt/data0/ashwin/07122012/S2-W006')
% % Analyze path
% info = get_path_info(waferpath);
% status.wafer = info.wafer;
% status.pipeline_script = mfilename;
% sec_nums = info.sec_nums;
% % Load default parameters
% default_params;
% align_stack_xy;
% load('S2-W006_Sec11_xy_aligned.mat')
% secs{11} = sec;
% load('S2-W006_Sec15_xy_aligned.mat')
% secs{15} = sec;
% 
% filename = sprintf('%s_xy_aligned.mat', secs{1}.wafer);
% save(filename, 'secs', 'error_log', '-v7.3');
% render_secs(secs, 0.02);
% 
% clearvars;
% 
% waferpath('/mnt/data0/ashwin/07122012/S2-W007')
% % Analyze path
% info = get_path_info(waferpath);
% status.wafer = info.wafer;
% status.pipeline_script = mfilename;
% sec_nums = info.sec_nums;
% % Load default parameters
% default_params; % set skipped tiles to 4
% align_stack_xy;
% % load('S2-W008_Sec1_xy_aligned.mat')
% % secs{1} = sec;
% 
% filename = sprintf('%s_xy_aligned_removed_tile4.mat', secs{1}.wafer);
% save(filename, 'secs', 'error_log', '-v7.3');
% render_secs(secs, 0.02);

% clearvars;
% 
% waferpath('/mnt/data0/ashwin/07122012/S2-W008')
% % Analyze path
% info = get_path_info(waferpath);
% status.wafer = info.wafer;
% status.pipeline_script = mfilename;
% sec_nums = info.sec_nums;
% % Load default parameters
% default_params; % set skipped tiles to 4

% start = 20;
% finish = length(sec_nums);
% align_stack_xy;
% filename = sprintf('%s_xy_aligned_removed_tile4.mat', secs{1}.wafer);
% save(filename, 'secs', 'error_log', '-v7.3');
% render_secs(secs, 0.02, '_xy_removed_tile4.tif');
% 
% clearvars;
% % SECTION 7 - ALL TILES
% waferpath('/mnt/data0/ashwin/07122012/S2-W007')
% % Analyze path
% info = get_path_info(waferpath);
% status.wafer = info.wafer;
% status.pipeline_script = mfilename;
% sec_nums = info.sec_nums;
% % Load default parameters
% default_params;
% start = 1;
% finish = length(sec_nums);
% align_stack_xy;
% 
% filename = sprintf('%s_xy_aligned.mat', secs{1}.wafer);
% save(filename, 'secs', 'error_log', '-v7.3');
% render_secs(secs, 0.02);
% 
% clearvars;
% % SECTION 7 - NO TILE 4 & TILE 16
% waferpath('/mnt/data0/ashwin/07122012/S2-W007')
% % Analyze path
% info = get_path_info(waferpath);
% status.wafer = info.wafer;
% status.pipeline_script = mfilename;
% sec_nums = info.sec_nums;
% % Load default parameters
% default_params_no_tile4_16;
% start = 1;
% finish = length(sec_nums);
% align_stack_xy;
% 
% filename = sprintf('%s_xy_aligned_removed_tile4_16.mat', secs{1}.wafer);
% save(filename, 'secs', 'error_log', '-v7.3');
% render_secs(secs, 0.02, '_xy_removed_tile4_16.tif');
% 
% clearvars;
% % SECTION 8 - NO TILE 4 & TILE 16
% waferpath('/mnt/data0/ashwin/07122012/S2-W008')
% % Analyze path
% info = get_path_info(waferpath);
% status.wafer = info.wafer;
% status.pipeline_script = mfilename;
% sec_nums = info.sec_nums;
% % Load default parameters
% default_params_no_tile4_16;
% start = 1;
% finish = 13;
% align_stack_xy;
% 
% start = 15;
% finish = length(sec_nums);
% align_stack_xy;
% 
% filename = sprintf('%s_xy_aligned_removed_tile4_16.mat', secs{1}.wafer);
% save(filename, 'secs', 'error_log', '-v7.3');
% render_secs(secs, 0.02, '_xy_removed_tile4_16.tif');
% 
% 

% Check all the xy alignment renders. Fix any problems.

% load('/home/tmacrina/StitchEM/results/S2-W006_xy_aligned.mat');
% rough_align_z;
% filename = sprintf('%s_rough_z_aligned.mat', secs{1}.wafer);
% save(filename, 'secs', 'error_log', '-v7.3');

% load('/home/tmacrina/StitchEM/results/S2-W007_xy_aligned.mat');
% rough_align_z;
% filename = sprintf('%s_rough_z_aligned.mat', secs{1}.wafer);
% save(filename, 'secs', 'error_log', '-v7.3');

% load('/home/tmacrina/StitchEM/results/S2-W008_xy_aligned.mat');
% rough_align_z;
% filename = sprintf('%s_rough_z_aligned.mat', secs{1}.wafer);
% save(filename, 'secs', 'error_log', '-v7.3');

% clearvars;
% % SECTION 7 - RECROPPED & NO TILE 4
% waferpath('/mnt/data0/ashwin/07122012/S2-W007')
% % Analyze path
% info = get_path_info(waferpath);
% status.wafer = info.wafer;
% status.pipeline_script = mfilename;
% sec_nums = info.sec_nums;
% % Load default parameters
% default_params_no_tile4;
% start = 51;
% finish = length(sec_nums);
% align_stack_xy;

% filename = sprintf('%s_xy_aligned_recropped_no_tile4.mat', secs{end}.wafer);
% save(filename, 'secs', 'error_log', '-v7.3');
% render_secs(secs, 0.02, '_xy_recropped_no_tile4.tif');
% 
% clearvars;
% % SECTION 7 - RECROPPED & NO TILE 4
% waferpath('/mnt/data0/ashwin/07122012/S2-W008')
% % Analyze path
% info = get_path_info(waferpath);
% status.wafer = info.wafer;
% status.pipeline_script = mfilename;
% sec_nums = info.sec_nums;
% % Load default parameters
% default_params;
% start = 3;
% finish = 3;
% align_stack_xy;

% filename = sprintf('%s_xy_aligned_recropped_no_tile4.mat', secs{end}.wafer);
% save(filename, 'secs', 'error_log', '-v7.3');
% render_secs(secs, 0.02, '_xy_recropped_no_tile4.tif');


% % W007
% clearvars;
% W007;
% start = 51;
% finish = length(sec_nums);
% align_stack_xy;
% 
% filename = sprintf('%s_xy_aligned_recropped.mat', secs{end}.wafer);
% save(filename, 'secs', 'error_log', '-v7.3');
% render_secs(secs, 0.02, '_xy_recropped.tif');
% 
% clearvars;
% W007;
% for s=51:length(params); params(s).xy.skip_tiles = [params(s).xy.skip_tiles 4]; end
% start = 51;
% finish = length(sec_nums);
% align_stack_xy;
% 
% filename = sprintf('%s_xy_aligned_recropped_no_tile4.mat', secs{end}.wafer);
% save(filename, 'secs', 'error_log', '-v7.3');
% render_secs(secs, 0.02, '_xy_recropped_no_tile4.tif');

% % W008
% clearvars;
% W008;
% start = 1;
% finish = length(sec_nums);
% align_stack_xy;
% 
% filename = sprintf('%s_xy_aligned_recropped.mat', secs{end}.wafer);
% save(filename, 'secs', 'error_log', '-v7.3');
% render_secs(secs, 0.02, '_xy_recropped.tif');
% 
% clearvars;
% W008;
% for s=1:length(params); params(s).xy.skip_tiles = [params(s).xy.skip_tiles 4]; end
% start = 1;
% finish = length(sec_nums);
% align_stack_xy;
% 
% filename = sprintf('%s_xy_aligned_recropped_no_tile4.mat', secs{end}.wafer);
% save(filename, 'secs', 'error_log', '-v7.3');
% render_secs(secs, 0.02, '_xy_recropped_no_tile4.tif');

% clearvars;
% W007;
% load('/home/tmacrina/StitchEM/results/S2-W007_xy_aligned.mat');
% start = 1;
% finish = length(secs);
% rough_align_z;
% filename = sprintf('%s_rough_z_aligned.mat', secs{1}.wafer);
% save(filename, 'secs', '-v7.3');

% align_stack_z;
% filename = sprintf('%s_fine_z_aligned.mat', secs{1}.wafer);
% save(filename, 'secs', '-v7.3');

% Fixes
% clearvars;
% W007;
% start = 47;
% finish = 47;
% align_stack_xy;
% 
% sec = secs{47};
% filename = sprintf('%s_Sec%d_xy_aligned.mat', sec.wafer, sec.num);
% save(filename, 'sec', '-v7.3')

% render_secs(secs, 0.02, '_xy_rendered.tif');
% 
% W008 rough z alignment
% start = 1;
% finish = length(secs);
% rough_align_z;
% 
% filename = sprintf('%s_rough_z_aligned.mat', secs{1}.wafer);
% save(filename, 'secs', '-v7.3');
% 
% % stack_align_z;
% filename = sprintf('%s_z_aligned_1_76.mat', secs{1}.wafer);
% save(filename, 'secs', '-v7.3');
% 
% for i = 1:length(secs)
%     if i ~= secs{i}.num-1
%         i
%     end
%     sec = imclear_sec(sec);
%     sec.features.xy.tiles = [];
% end

% Fix W008 Sec12/13
% Fix W008 Sec54/55

% clearvars;
% W008;
% start = 53;
% finish = 54;
% align_stack_xy
% 
% sec = secs{54};
% 
% % Save the section
% filename = sprintf('%s_Sec%d_xy_aligned.mat', sec.wafer, sec.num);
% save(filename, 'sec', '-v7.3')
% 
% % Save the render
% section = render_section(sec, 'xy', 'scale', 0.02);
% filename = sprintf('%s/%s_xy_rendered.tif', sec.wafer, sec.name);
% imwrite(section, fullfile(cachepath, filename));
% imshow(section)

% n = [101 102 141 143 145 35 36 68 69 78 82 84 93];
% for i=n
%     filename = sprintf('S2-W008_Sec%d_xy_aligned.mat', i);
%     load(filename);
%     sec = imclear_sec(sec);
%     sec.features.xy.tiles = [];
%     whos('sec');
%     reprocess_xy_new_matches;
% end

clearvars;
W006;