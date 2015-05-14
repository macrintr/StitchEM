function sec = update_rough_xy_for_overview_cropping(sec)
% Update rough_xy & xy alignments for unaccounted overview cropping
% Error caught 150422

s = 0.07;
% scaling = affine2d([s 0 0; 0 s 0; 0 0 1]);

if (strcmp(sec.wafer, 'S2-W007') && sec.num >= 51) || strcmp(sec.wafer, 'S2-W008')
    tx = sec.overview.size(1) * 0.33 / s;
    ty = sec.overview.size(2) * 0.16 / s;
else
    tx = sec.overview.size(1) * 0.25 / s;
    ty = sec.overview.size(2) * 0.25 / s;
end
translation = affine2d([1 0 0; 0 1 0; tx ty 1]);

for i = 1:length(sec.alignments.rough_xy.tforms)
    rel_tform = sec.alignments.rough_xy.rel_tforms{i};
    sec.alignments.rough_xy.rel_tforms{i} = affine2d(rel_tform.T * translation.T);
    tform = sec.alignments.rough_xy.tforms{i};
    sec.alignments.rough_xy.tforms{i} = affine2d(tform.T * translation.T);
    sec.alignments.rough_xy.note = 'update_xy_alignments_for_overview_cropping';
    
%     xy_tform = sec.alignments.xy.rel_tforms{i};
%     sec.alignments.xy.tforms{i} = affine2d(tform.T * translation.T * xy_tform.T);
%     sec.alignments.xy.note = 'update_xy_alignments_for_overview_cropping';
end
