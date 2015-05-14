for i=1:length(secs)
	secs{i} = update_rough_xy_for_overview_cropping(secs{i});
    secs = update_sec_tforms(secs, i);
end
% secs{79} = secA;
