W001_path = '/usr/people/tmacrina/seungmount/research/GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-W001/HighResImages_ROI1_7nm_120apa/';
W002_path = '/usr/people/tmacrina/seungmount/research/GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-W002/HighResImages_ROI1_W002_7nm_120apa/';
W003_path = '/usr/people/tmacrina/seungmount/research/GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-W003/HighResImages_ROI1_7nm_120apa/';

for i = 1:length(secs)
    if secs{i}.wafer == 'S2-W001'
        secs{i} = adjust_sec_paths(secs{i}, W001_path);
    elseif secs{i}.wafer == 'S2-W002'
        secs{i} = adjust_sec_paths(secs{i}, W002_path);
    elseif secs{i}.wafer == 'S2-W003'
        secs{i} = adjust_sec_paths(secs{i}, W003_path);
    end
end