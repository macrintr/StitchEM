%% Configuration
%secs = [wafers{1}(end-5:end); wafers{2}(1:5)];
% secs = vertcat(wafers{:});
alignment = 'z';
scale = 1;
CLAHE = true;

output_folder = fullfile(renderspath, sprintf('S2-W001-W002_jitter_1_2_z_%sx', num2str(scale)));

%% Stack ref
Rs = cell(length(secs), 1);
for s = 1:50
    % For convenience
    sec = secs{s};
    sizes = sec.tile_sizes;
    tforms = sec.alignments.(alignment).tforms;
    
    % Refs before alignment
    initial_Rs = cellfun(@imref2d, sec.tile_sizes, 'UniformOutput', false);
    
    % Scale
    initial_Rs = cellfun(@(R) scale_ref(R, scale), initial_Rs, 'UniformOutput', false);
    
    % Estimate spatial references after alignment
    Rs{s} = cellfun(@tform_spatial_ref, initial_Rs', tforms, 'UniformOutput', false);
end

% Flatten and merge spatial refs
Rs = vertcat(Rs{:});
stack_R = merge_spatial_refs(Rs);
disp('Merged stack refs.')


crop_starts = [int64(stack_R.ImageSize(1)/2 - 500) int64(stack_R.ImageSize(2)/2 - 500);
                int64(stack_R.ImageSize(1)/3) int64(stack_R.ImageSize(2)/3);
                int64(stack_R.ImageSize(1)*2/3) int64(stack_R.ImageSize(2)/3);
                int64(stack_R.ImageSize(1)/3) int64(stack_R.ImageSize(2)*2/3);
                int64(stack_R.ImageSize(1)*2/3) int64(stack_R.ImageSize(2)*2/3)];

%% Render sections
for s = 1:2
    % Render
    rendered = render_section(secs{s}, alignment, stack_R, 'scale', scale);
    
    % CLAHE
    if CLAHE
        rendered = adapthisteq(rendered);
    end
    
    % Write to disk
    if s == 1
        folder_path = create_folder(output_folder);
    end
    
    for i=1:length(crop_starts)
        imwrite(rendered(crop_starts(i, 1):crop_starts(i, 1)+1000, crop_starts(i, 2):crop_starts(i, 2)+1000), fullfile(output_folder, [num2str(i) 'C_' secs{s}.name '.tif']))
    end
end
clear rendered