function lines = matched_features(sec)
lines = [];
blue = uint8([0 0 255]);
for m = 1:size(sec.xy_matches.inliers.A,1)
    if ~isempty(sec.xy_matches.inliers.A{m})
        A_idx = sec.xy_matches.inliers.A{m}.tile(1);
        [A_row, A_col] = find(sec.grid==A_idx);
        A_width = sec.tile_sizes{A_idx}(1);
        A_height = sec.tile_sizes{A_idx}(2);

        A_coords = sec.xy_matches.inliers.A{m}.local_points;

        B_idx = sec.xy_matches.inliers.B{m}.tile(1);
        [B_row, B_col] = find(sec.grid==B_idx);
        B_width = sec.tile_sizes{B_idx}(1);
        B_height = sec.tile_sizes{B_idx}(2);

        B_coords = sec.xy_matches.inliers.B{m}.local_points;

        A_global = [A_coords(:,1) + A_width*(A_col-1) A_coords(:,2) + A_height*(A_row-1)];
        B_global = [B_coords(:,1) + B_width*(B_col-1) B_coords(:,2) + B_height*(B_row-1)];
        lines = [lines; A_global B_global];  
    end
end
        

% lineInserter = vision.ShapeInserter('Shape', 'Lines', 'BorderColor', 'Custom', 'CustomBorderColor', blue);
% big_image = step(lineInserter, sec_stitch, lines);

filename = 'Section_No.tif';
% imwrite(sec_stitch, fullfile(cachepath, filename));

