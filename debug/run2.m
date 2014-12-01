try
    clearvars;
    clc;
    load('results/S2-W002_rough_z_aligned.mat');
    clear('status');
    waferpath('/mnt/data0/ashwin/07122012/S2-W002')
    info = get_path_info(waferpath);
    wafer = info.wafer;
    sec_nums = info.sec_nums;
    % Load default parameters
    default_params
    params(2).z.matching_mode = 'manual';
    params(17).z.matching_mode = 'manual';
    params(18).z.matching_mode = 'manual';
    params(20).z.matching_mode = 'manual';
    params(71).z.matching_mode = 'manual';
    params(72).z.matching_mode = 'manual';
    params(88).z.matching_mode = 'manual';
    params(89).z.matching_mode = 'manual';
    params(105).z.matching_mode = 'manual';
    params(134).z.matching_mode = 'manual';
    params(135).z.matching_mode = 'manual';
    params(136).z.matching_mode = 'manual';
    
    start = 1;
    finish = length(secs);
%     rough_align_z;
    align_stack_z_loop;
catch
end
% 
% clc;
% 
% try
%     clearvars;
%     load('results/S2-W001_rough_z_aligned.mat');
%     clear('status');
%     waferpath('/mnt/data0/ashwin/07122012/S2-W001')
%     info = get_path_info(waferpath);
%     wafer = info.wafer;
%     sec_nums = info.sec_nums;
%     % Load default parameters
%     default_params
% %     load('S2-W001_z_aligned_W001_Sec40.mat');
% %     secs{40} = secB;
% %     rough_align_z;
%     start = 1;
%     finish = 53;    
%     align_stack_z;
%     secs{53} = propagate_z_for_missing_tiles(secs{52}, secs{53})
%     start = 54;
%     finish = size(secs, 1);
%     align_stack_z;
% catch
% end
% 
% try
%     clearvars;
%     load('results/S2-W003_rough_z_aligned.mat');
%     clear('status');
%     waferpath('/mnt/data0/ashwin/07122012/S2-W003')
%     info = get_path_info(waferpath);
%     wafer = info.wafer;
%     sec_nums = info.sec_nums;
%     % Load default parameters
%     default_params
%     start = 1;
%     finish = size(secs, 1);
% %     load('S2-W003_z_aligned_Sec115.mat');
% %     secs{115} = secB;    
% %     load('S2-W003_z_aligned_Sec116.mat');
% %     secs{116} = secB;    
% %     rough_align_z;
%     params(140).z.matching_mode = 'manual';
%     params(141).z.matching_mode = 'manual';
%     align_stack_z;
% catch
% end

try
    clearvars;
    load('results/S2-W004_rough_z_aligned.mat');
    clear('status');
    waferpath('/mnt/data0/ashwin/07122012/S2-W004')
    info = get_path_info(waferpath);
    wafer = info.wafer;
    sec_nums = info.sec_nums;
    % Load default parameters
    default_params
    start = 1;
    finish = 43;
    align_stack_z;
    secs{43} = propagate_z_for_missing_tiles(secs{42}, secs{43});
    start = 43;
    finish = size(secs, 1);
    align_stack_z;
%     rough_align_z;
catch
end

try
    clearvars;
    load('results/S2-W001_z_aligned.mat');
    render;
catch
end

% try
%     clearvars;
%     load('results/S2-W005_xy_aligned.mat');
%     clear('status');
%     waferpath('/mnt/data0/ashwin/07122012/S2-W005')
%     info = get_path_info(waferpath);
%     wafer = info.wafer;
%     sec_nums = info.sec_nums;
%     % Load default parameters
%     default_params
%     start = 1;
%     finish = size(secs, 1);
%     rough_align_z;
%     align_stack_z;
% catch
% end
% 
% try
%     clearvars;
%     waferpath('/mnt/data0/ashwin/07122012/S2-W006')
%     info = get_path_info(waferpath);
%     wafer = info.wafer;
%     sec_nums = info.sec_nums;
%     % Load default parameters
%     default_params
%     align_stack_xy;
%     start = 1;
%     finish = size(secs, 1);
%     rough_align_z;
% catch
% end
% 
% try
%     clearvars;
%     waferpath('/mnt/data0/ashwin/07122012/S2-W007')
%     info = get_path_info(waferpath);
%     wafer = info.wafer;
%     sec_nums = info.sec_nums;
%     % Load default parameters
%     default_params
%     align_stack_xy;
%     start = 1;
%     finish = size(secs, 1);
%     rough_align_z;
% catch
% end
% 
% try
%     clearvars;
%     waferpath('/mnt/data0/ashwin/07122012/S2-W008')
%     info = get_path_info(waferpath);
%     wafer = info.wafer;
%     sec_nums = info.sec_nums;
%     % Load default parameters
%     default_params
%     align_stack_xy;
%     start = 1;
%     finish = size(secs, 1);
%     rough_align_z;
% catch
% end