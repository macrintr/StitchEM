function current_path = renderpath(new_path)
%RENDERPATH Gets or sets the renders path.
% Usage:
%   current_path = renderpath
%   renderpath(new_path)

global ProgramPaths;

% Update
if nargin > 0
    ProgramPaths.base = GetFullPath(new_path);    
    ProgramPaths.rough_xy = fullfile(ProgramPaths.base, 'rough_xy');
    ProgramPaths.xy = fullfile(ProgramPaths.base, 'xy');
    ProgramPaths.rough_z = fullfile(ProgramPaths.base, 'rough_z');
    ProgramPaths.overview_rough_z = fullfile(ProgramPaths.base, 'overview_rough_z');
    ProgramPaths.z = fullfile(ProgramPaths.base, 'z');
    
    disp('Set render path.')
    
    check_path_and_create_directory_if_necessary(ProgramPaths.base);
    check_path_and_create_directory_if_necessary(ProgramPaths.rough_xy);
    check_path_and_create_directory_if_necessary(ProgramPaths.xy);
    check_path_and_create_directory_if_necessary(ProgramPaths.rough_z);
    check_path_and_create_directory_if_necessary(ProgramPaths.overview_rough_z);
    check_path_and_create_directory_if_necessary(ProgramPaths.z);
end

% Return current
current_path = ProgramPaths;
end

function check_path_and_create_directory_if_necessary(path)
% Check if path exists, otherwise create that folder
%
% check_path_and_create_directory_if_necessary(path)

if ~exist(path, 'dir')
    choice = questdlg(['Create new folder here: ' path '?'], ...
                        'Create folder?', 'Yes', 'No', 'Yes');
    if strcmp(choice, 'Yes')
        mkdir(path);
        disp(['Created folder: ' path]);
    end
end
end