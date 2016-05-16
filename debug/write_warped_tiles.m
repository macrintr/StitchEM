sec = secs{21};
t = cell(3,1)
for i  = 1:sec.num_tiles
    tile = imread(sec.tile_paths{i});
    tform = sec.alignments.xy.tforms{i};
    tic; [A, RA] = imwarp(tile, tform); toc;
    name_start = strfind(sec.tile_paths{i}, 'Tile_r');
    name = sec.tile_paths{i}(name_start:end)
    t{i,1} = name
    t{i,2} = RA.XWorldLimits(1)
    t{i,3} = RA.YWorldLimits(2)
%     RA
%     imwrite(A, ['../' name]);
end
cell2table(t)