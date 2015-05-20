snames = fieldnames(secs{2});
bytes = 0;
for i = 1:numel(snames)
    stuff = secs{2}.(snames{i});
    snames{i};
    a = whos('stuff');
    bytes = bytes + a.bytes;
end
bytes / 1000000