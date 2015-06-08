function imshow_tile_on_overview(sec, tile_num)
% Display overview with tile overlaid

rough_z = 1;

s = sec.params.rough_xy.overview_to_tile_resolution_ratio;
S = [s 0 0; 0 s 0; 0 0 1];
sec = load_overview(sec);
overview = sec.overview.img;
tile = imread(sec.tile_paths{tile_num});

if rough_z
    tformO = sec.overview.alignments.rough_z.tform;
%     tformO = affine2d(S^-1 * tformO.T * S);
    tformT = sec.alignments.rough_z.tforms{tile_num};
else
    tformO = sec.overview.alignments.initial.tform;
    tformT = sec.alignments.rough_xy.tforms{tile_num};
end
tformTS = affine2d(tformT.T * S);

[overview, overview_spatial_ref] = imwarp(overview, tformO);
[tile, tile_spatial_ref] = imwarp(tile, tformTS);
[merge, merge_spatial_ref] = imfuse(overview, overview_spatial_ref, tile, tile_spatial_ref);
figure
imshow(merge, merge_spatial_ref);