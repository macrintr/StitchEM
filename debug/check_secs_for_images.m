for i=1:length(secs)
    if size(secs{i}.overview.img)
        disp([num2str(i) ' overview'])
        secs{i}.overview.img = [];
    end
    if size(secs{i}.tiles, 1) > 1
        disp([num2str(i) ' tile ' num2str(j)])
    end
end
