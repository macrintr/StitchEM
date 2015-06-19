function secs = cleanup_pre_20150428_secs(secs, params)
% Cleanup secs attribute names and overview alignments
%
% Inputs:
%   secs: cell array of section structs
%
% Outputs:
%   secs: cell array of section structs
%
% secs = cleanup_pre_20150428_secs(secs)

start = 1;
finish = length(secs);

for i=start:finish
    if isfield(secs{i}.alignments, 'rough_z_xy')
        secs{i}.alignments.rough_z = secs{i}.alignments.rough_z_xy;
        secs{i}.alignments = rmfield(secs{i}.alignments, 'rough_z_xy');
    end
end

for i=start:finish
    secs{i} = imclear_sec(secs{i});
    secs{i}.params = params(i);
end

W001_path = '/usr/people/tmacrina/seungmount/research/GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-W001/HighResImages_ROI1_7nm_120apa/';
W002_path = '/usr/people/tmacrina/seungmount/research/GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-W002/HighResImages_ROI1_W002_7nm_120apa/';
W003_path = '/usr/people/tmacrina/seungmount/research/GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-W003/HighResImages_ROI1_7nm_120apa/';
W004_path = '/usr/people/tmacrina/seungmount/research/GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-W004/HighResImages_ROI1_W004_7nm_120apa/';
W005_path = '/usr/people/tmacrina/seungmount/research/GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-W005/HighResImages_ROI1_W005_7nm_120apa/';
W006_path = '/usr/people/tmacrina/seungmount/research/GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-W006/HighResImages_ROI1_W006_7nm_120apa/';
W007_path = '/usr/people/tmacrina/seungmount/research/GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-W007/HighResImages_W007_ROI1_7nm_120apa/';
W008_path = '/usr/people/tmacrina/seungmount/research/GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-W008/HighResImages_W008_ROI1_7nm_120apa/';

for i=start:finish
    if secs{i}.wafer == 'S2-W001'
        secs{i} = adjust_sec_paths(secs{i}, W001_path);
    elseif secs{i}.wafer == 'S2-W002'
        secs{i} = adjust_sec_paths(secs{i}, W002_path);
    elseif secs{i}.wafer == 'S2-W003'
        secs{i} = adjust_sec_paths(secs{i}, W003_path);
    elseif secs{i}.wafer == 'S2-W004'
        secs{i} = adjust_sec_paths(secs{i}, W004_path);
    elseif secs{i}.wafer == 'S2-W005'
        secs{i} = adjust_sec_paths(secs{i}, W005_path);
    elseif secs{i}.wafer == 'S2-W006'
        secs{i} = adjust_sec_paths(secs{i}, W006_path);
    elseif secs{i}.wafer == 'S2-W007'
        secs{i} = adjust_sec_paths(secs{i}, W007_path);
    elseif secs{i}.wafer == 'S2-W008'
        secs{i} = adjust_sec_paths(secs{i}, W008_path);
    end
end

for i=start:finish
    if isfield(secs{i}.overview, 'alignment')
        secs{i}.overview.alignments.initial = secs{i}.overview.alignment;
        secs{i}.overview = rmfield(secs{i}.overview, 'alignment');
    end
    if isfield(secs{i}.overview, 'rough_align_z')
        secs{i}.overview.alignments.rough_z = secs{i}.overview.rough_align_z;
        secs{i}.overview = rmfield(secs{i}.overview, 'rough_align_z');
        secs{i}.overview.alignments.rough_z.tform = secs{i}.overview.alignments.rough_z.tforms;
        secs{i}.overview.alignments.rough_z.rel_tform = secs{i}.overview.alignments.rough_z.rel_tforms;
        secs{i}.overview.alignments.rough_z = rmfield(secs{i}.overview.alignments.rough_z, 'tforms');
        secs{i}.overview.alignments.rough_z = rmfield(secs{i}.overview.alignments.rough_z, 'rel_tforms');
    end
    if isfield(secs{i}.overview, 'scale')
        secs{i}.overview = rmfield(secs{i}.overview, 'scale');
        secs{i}.overivew.overview_to_tile_resolution_ratio = 0.07;
    end
    if isfield(secs{i}, 'overview_to_tile_resolution_ratio')
        secs{i} = rmfield(secs{i}, 'overview_to_tile_resolution_ratio');
    end
end

cleanup_overview_rough_z_data;

for s=1:length(secs)
    secs = clean_xy_matches(secs, s, 200);
    secs = clean_xy_matches(secs, s, 100);
    secs = clean_xy_matches(secs, s, 50);
    secs = clean_xy_matches(secs, s, 25);
    secs = clean_xy_matches(secs, s, 15);
    % Export xy check
    imwrite_section_plot(secs{s}, 'xy', 'xy');
    imwrite_xy_residuals(secs{s}, 'xy');
    
    secs = update_sec_tforms(secs, s);
    
    secs = clean_z_matches(secs, s, 200);
    secs = clean_z_matches(secs, s, 120);
    
    secs = update_sec_tforms(secs, s);
end

% for i=start:finish
%     secs{i} = update_rough_xy_for_overview_cropping(secs{i});
%     secs = update_sec_tforms(secs, i);
% end