function imshow_tile_on_overview(sec, tile_num)
% Display overview with tile overlaid

rough_z_xy = 1;

tile_to_overview_scale = 0.07;
S = [tile_to_overview_scale 0 0; 0 tile_to_overview_scale 0; 0 0 1];
sec = load_overview(sec, 1);
overview = sec.overview.img;
tile = imread(sec.tile_paths{tile_num});

if rough_z_xy
    tformO = sec.overview.rough_align_z.tforms;
    tformO = affine2d(S^-1 * tformO.T * S);
    tformT = sec.alignments.rough_z_xy.tforms{tile_num};
else
    tformO = sec.overview.alignment.tform;
    tformT = sec.alignments.rough_xy.tforms{tile_num};
end
tformTS = affine2d(tformT.T * S);

[overview, overview_spatial_ref] = imwarp(overview, tformO);
[tile, tile_spatial_ref] = imwarp(tile, tformTS);
[merge, merge_spatial_ref] = imfuse(overview, overview_spatial_ref, tile, tile_spatial_ref);
figure
imshow(merge, merge_spatial_ref);