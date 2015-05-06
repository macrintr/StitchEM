for i = 1:length(secs)
    secs{i} = update_rough_xy_for_overview_cropping(secs{i});
end
secs = propagate_tforms(secs, 1);