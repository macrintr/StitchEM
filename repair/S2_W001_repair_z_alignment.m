clearvars;
clc;
load('results/S2-W001_xy_aligned.mat');

start = 46;
finish = 54;

if start < 39
    secs = rough_align_z(secs, start, 39, start);
    fix_S2_W001_Sec40_z;
    secs = rough_align_z(secs, 41, finish, start);
else
    secs = rough_align_z(secs, start, finish, start);
end
    

waferpath('/mnt/data0/ashwin/07122012/S2-W001')
info = get_path_info(waferpath);
wafer = info.wafer;
sec_nums = info.sec_nums;
sec_nums(103) = []; % skip

% Load default parameters
default_params

clear('status');

align_stack_z;