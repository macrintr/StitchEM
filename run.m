% clearvars;
% % load('S2-W001_xy_aligned.mat');
% % fix_S2_W001_Sec15;
% % fix_S2_W001_Sec20;
% % fix_S2_W001_Sec59;
% % fix_S2_W001_Sec104;
% load('S2-W001_xy_aligned_fixed.mat');
% render_secs(secs, 0.08);
% clearvars;
% load('S2-W002_xy_aligned_3.mat');
% render_secs(secs, 0.08);
% clearvars;
% load('S2-W003_xy_aligned_2.mat');
% render_secs(secs, 0.08);


% waferpath('/mnt/data0/ashwin/07122012/S2-W002')
% % waferpath('/data/home/talmo/EMdata/W002')
% info = get_path_info(waferpath);
% wafer = info.wafer;
% sec_nums = info.sec_nums;
% 
% % Load default parameters
% default_params
% 
% % pairs = unique([sec.z_matches.A.tile sec.z_matches.B.tile], 'rows');

% clearvars;
% load('S2-W003_xy_aligned_2.mat');
% W003;
% render_secs(secs, 0.08);
% clearvars;
% W004;
% render_secs(secs, 0.08);
% clearvars;
% W005;
% render_secs(secs, 0.08);
% clearvars;
% W006;
% render_secs(secs, 0.08);
% clearvars;
% W007;
% render_secs(secs, 0.08);
% clearvars;

% secA = secs{4};
% secB = secs{5};
% [tform_moving, varargout, stats] = register_overviews(secB, secA);

% Figure 3 corresponds to Section 3 to Section 4

% for n=1:29
%     m = n+1;
%     secA = secs{n};
%     secB = secs{m};
%     [tform_moving, varargout, stats] = register_overviews(secB, secA);
%     [tform_moving, varargout, stats] = register_overviews(secA, secB);
% end

%     secA = secs{63};
%     secB = secs{64};
%     [tform_moving, varargout, stats] = register_overviews(secB, secA);


% a = 2:30;
% b = 1:29;
% c = [a' b'];
% d = [b' a'];
% e = [];
% for i=1:29
%     for j=1:2
%         if j==1
%             e(end+1, :) = c(i, :);
%         else
%             e(end+1, :) = d(i, :);
%         end
%     end
% end
% 
% f = [1:5 3:55];
% g = [e f'];
% 
%     13    14    23
%     30    29    54
%     29    30    55


% rough_align_z;
% 
% %% Configuration
% % Wafer and sections
% waferpath('/mnt/data0/ashwin/07122012/S2-W001')
% info = get_path_info(waferpath);
% wafer = info.wafer;
% sec_nums = info.sec_nums;
% sec_nums(103) = []; % skip
% 
% % Load default parameters
% default_params
% clear('status');

align_stack_z;

clearvars;
load('/home/tmacrina/StitchEM/results/S2-W002_xy_aligned.mat')
rough_align_z;
%% Configuration
% Wafer and sections
waferpath('/mnt/data0/ashwin/07122012/S2-W002')
info = get_path_info(waferpath);
wafer = info.wafer;
sec_nums = info.sec_nums;
% Load default parameters
default_params
clear('status');
align_stack_z;

clearvars;
load('/home/tmacrina/StitchEM/results/S2-W003_xy_aligned.mat')
rough_align_z;
%% Configuration
% Wafer and sections
waferpath('/mnt/data0/ashwin/07122012/S2-W003')
info = get_path_info(waferpath);
wafer = info.wafer;
sec_nums = info.sec_nums;
% Load default parameters
default_params
clear('status');
align_stack_z;

clearvars;
load('/home/tmacrina/StitchEM/results/S2-W004_xy_aligned.mat')
rough_align_z;
%% Configuration
% Wafer and sections
waferpath('/mnt/data0/ashwin/07122012/S2-W004')
info = get_path_info(waferpath);
wafer = info.wafer;
sec_nums = info.sec_nums;
% Load default parameters
default_params
clear('status');
align_stack_z;

clearvars;
load('/home/tmacrina/StitchEM/results/S2-W005_xy_aligned.mat')
rough_align_z;
%% Configuration
% Wafer and sections
waferpath('/mnt/data0/ashwin/07122012/S2-W005')
info = get_path_info(waferpath);
wafer = info.wafer;
sec_nums = info.sec_nums;
% Load default parameters
default_params
clear('status');
align_stack_z;


% filename = sprintf('%s/%s_stitched_z_%d_%d.tif', sec.wafer, sec.wafer, sec.num);
% imwrite(section, fullfile(cachepath, filename));

% [ptsB, ptsA] = cpselect(secB, secA, 'Wait', true);

transformType = 'similarity';
sampleSize = 2;
maxNumTrials = 1000;
Confidence = 99;
MaxDistance = 1.5;

[tform, moving_inliers, fixed_inliers] = estimateGeometricTransform(ptsB, ptsA);


[fixed, fixed_spatial_ref] = imwarp(secA.overview.img, secA.alignments.rough_z.rel_tforms{1});
[moving, moving_spatial_ref] = imwarp(secB.overview.img, secB.alignments.rough_z.rel_tforms{1});
[merge, merge_spatial_ref] = imfuse(fixed, fixed_spatial_ref, moving, moving_spatial_ref);