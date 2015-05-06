function imshow_tile_on_overview(sec, tile_num)
% Display overview with tile overlaid

tile_to_overview_scale = 0.07;
sec = load_overview(sec, 1);
overview = sec.overview.img;
tformO = sec.overview.alignment.tform;

tile = imread(sec.tile_paths{tile_num});
tformT = sec.alignments.rough_xy.tforms{tile_num};

S = [tile_to_overview_scale 0 0; 0 tile_to_overview_scale 0; 0 0 1];
tformTS = affine2d(tformT.T * S);

[overview, overview_spatial_ref] = imwarp(overview, tformO);
[tile, tile_spatial_ref] = imwarp(tile, tformTS);
[merge, merge_spatial_ref] = imfuse(overview, overview_spatial_ref, tile, tile_spatial_ref);
figure
imshow(merge, merge_spatial_ref);