function print_missing_tiles(secs)
% Print out missing tiles and their sections

fprintf('tile row col\n');
for s = 1:length(secs)
    if find(~secs{s}.grid)
        [row, col] = find(~secs{s}.grid);
        fprintf('%s %d %d\n', secs{s}.name, row, col);
    end
end
        