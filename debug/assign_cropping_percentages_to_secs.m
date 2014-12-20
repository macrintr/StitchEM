for i=1:length(secs)
    if i < 51
        secs{i}.alignments.rough_xy.meta.cropping_percentages = [0.25 0.25 0.5 0.5];
    else
        secs{i} = secsB{i};
        secs{i}.alignments.rough_xy.meta.cropping_percentages = [0.3300 0.1600 0.5700 0.5700];
    end
end