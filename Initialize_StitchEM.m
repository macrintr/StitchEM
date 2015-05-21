% Prepares the MATLAB environment so you can use StitchEM correctly.

%% Configuration Instructions
% To change the patterns used to look for sections/tiles, modify:
%   functions/IO/get_path_info.m

% To change the path to the cache folder, call: waferpath(new_path)

%% Paths
% Add StitchEM files to MATLAB search path
addpath(pwd);
addpath(genpath(fullfile(pwd, 'functions')));
addpath(genpath(fullfile(pwd, 'pipeline')));
addpath(genpath(fullfile(pwd, 'debug')));
addpath(genpath(fullfile(pwd, 'classes')));
addpath(genpath(fullfile(pwd, 'development')));

renderpath('/home/usr/tmacrina/seungmount/research/tommy');

% Set the current wafer path
% waferpath('/data/home/talmo/EMdata/W002');
% waferpath('/data/home/talmo/EMdata/S2-W003');

clear ans