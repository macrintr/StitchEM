function secs = add_xy_matches(secs, sec_num, tileA_num, tileB_num)
% Add xy_matches to a given seam

if length(tileA_num) == length(tileB_num)
    for i = 1:length(tileA_num)
        tileA = tileA_num(i);
        tileB = tileB_num(i);
        
        tformA = secs{sec_num}.alignments.rough_xy.tforms{tileA};
        tformB = secs{sec_num}.alignments.rough_xy.tforms{tileB};
        
        imgA = imread(secs{sec_num}.tile_paths{tileA});
        imgB = imread(secs{sec_num}.tile_paths{tileB});
        
        [ptsB, ptsA] = cpselect(imgB, imgA, 'Wait', true);
        A = table();
        B = table();
        
        A.local_points = ptsA;
        A.global_points = transformPointsForward(tformA, ptsA);
        A.tile = tileA * ones(length(ptsA), 1);
        
        B.local_points = ptsB;
        B.global_points = transformPointsForward(tformB, ptsB);
        B.tile = tileB * ones(length(ptsB), 1);
        
        secs{sec_num}.xy_matches.A = [secs{sec_num}.xy_matches.A; A];
        secs{sec_num}.xy_matches.B = [secs{sec_num}.xy_matches.B; B];
        
    end
    secs{sec_num}.alignments.xy = align_xy(secs{sec_num});
%     secs = propagate_tforms(secs, sec_num);
end


