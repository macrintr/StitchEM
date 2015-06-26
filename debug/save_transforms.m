% clearvars;
% load('S2-W001_clean_matches_working.mat');
% W001;

folder = ['/usr/people/tmacrina/seungmount/research/tommy/150502_piriform/affine_transforms/'];

start = 1;
finish = length(secs);
for i = start:finish
    for j = 1:length(secs{i}.tile_paths)
        tile_path = secs{i}.tile_paths{j};
        n = strfind(tile_path, 'Tile');
        tile_name = tile_path(n:end-4);
        % filename = ['affine_transform_' secs{i}.wafer '_section_' sprintf('%03d', secs{i}.num) '_name_' tile_name '.csv'];
        filename = [tile_name '.csv'];
        dlmwrite([folder filename], secs{i}.alignments.z.tforms{j}.T);
        % disp(filename);
    end
end