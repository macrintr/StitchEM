function sec = imload_section_tiles_repmat(sec)
% Load tiles for a section, and retile as 1,1,3 for color annotations

sec.tiles.full.img = imload_section_tiles(sec, 1.0);
for i=1:length(sec.tiles.full.img)
    sec.tiles.full.img{i} = repmat(sec.tiles.full.img{i}, [1,1,3]);
end