function display_multi_missing_tile_sections(secs)
% Display index of back-to-back missing tile sections

for s = 2:length(secs)
    k = secs{s}.params.z.rel_to;
    a = secs{s+k}.grid;
    b = secs{s}.grid;
    if sum(sum(~a .* ~b))
        fprintf('%d\n', s);
    end
end