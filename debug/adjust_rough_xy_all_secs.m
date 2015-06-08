for i=170:length(secs)
    if i ~= 168 + 70 && i ~= 168 + 87 && i ~= 168 + 134
        secs{i} = update_rough_xy_for_overview_cropping(secs{i});
        secs = update_sec_tforms(secs, i);
    end
end
