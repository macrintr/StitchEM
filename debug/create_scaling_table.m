function scale_table = create_scaling_table(secs)
% Create table of each rel_tforms determinant (each scaling factor)
%
% Inputs:
%   secs: cell array of section structs
%
% Outputs:
%   scale_table: table with one row per section, containing determinants of
%   the rel_tform of each tile alignment. final alignment is the tform (not
%   rel_tform) of z. pre_prod is the product of rough_z, prev_z, and z from
%   the prior section and should match the current prev_z. final_prod is
%   the product of all the rel_tform determinants, and should equal final.
%
% scale_table = create_scaling_table(secs)

d = [];
tile = 5;
for s = 1:length(secs)
    d = [d; s, det(secs{s}.alignments.rough_xy.rel_tforms{tile}.T), ...
        det(secs{s}.alignments.xy.rel_tforms{tile}.T), ...
        det(secs{s}.alignments.rough_z.rel_tforms{tile}.T), ...
        det(secs{s}.alignments.prev_z.rel_tforms{tile}.T), ...
        det(secs{s}.alignments.z.rel_tforms{tile}.T), ...
        det(secs{s}.alignments.z.tforms{tile}.T)];
end

d = table(d(:, 1), d(:, 2), d(:, 3), d(:, 4), d(:, 5), d(:, 6), d(:, 7), ...
        'VariableNames', {'idx', 'rough_xy', 'xy', 'rough_z', 'prev_z', 'z', 'final'});
d.pre_prod = d.rough_z .* d.prev_z .* d.z;
d.final_prod = d.rough_xy .* d.xy .* d.rough_z .* d.prev_z .* d.z;
scale_table = d;

name = ['scaling factor histograms for tile ' num2str(tile)];
figure('name', name);
title(name);

subplot(3, 2, 1);
histogram(d.rough_xy);
title('rough xy');

subplot(3, 2, 2);
histogram(d.xy);
title('xy');

subplot(3, 2, 3);
histogram(d.rough_z);
title('rough z');

subplot(3, 2, 4);
histogram(d.prev_z);
title('prev z');

subplot(3, 2, 5);
histogram(d.z);
title('z');

subplot(3, 2, 6);
histogram(d.final);
title('final');

