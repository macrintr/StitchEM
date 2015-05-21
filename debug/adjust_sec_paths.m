function sec = adjust_sec_paths(sec, new_path)
% Replace the preceding path directories before section image folder
%
% Inputs:
%   sec: the section struct for which the paths will be adjusted
%   new_path: string containing the new preceding path from the root

% Update overall section path (not really used, but for consistency)
location_of_path_to_keep = findstr(sec.name, sec.path);
sec.path = [new_path sec.path(location_of_path_to_keep:end)];

% Update tile paths
location_of_path_to_keep = findstr(sec.name, sec.tile_paths{1});
sec.tile_paths = cellfun(@(x) [new_path x(location_of_path_to_keep:end)], sec.tile_paths, 'UniformOutput', false);

% Update overview path
location_of_path_to_keep = findstr(sec.name, sec.overview.path);
sec.overview.path = [new_path sec.overview.path(location_of_path_to_keep:end)];

