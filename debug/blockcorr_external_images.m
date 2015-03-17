%% Create secs object
folder = 'ElasticExport03';
filepath = ['~/StitchEM/renders/S2-W001-W002_clean_matches_1_10/' folder '/'];
secs = cell(10, 1);

% Add section filepaths
for i = 1:10
    n = sprintf('%02i', i+1);
    secs{i}.filepath = [filepath n '____z' num2str(i) '.0.tif'];
end


%% Determine blockcorr against prior section
grid_sz = 300;
block_sz = 300;
search_sz = 75; % around block
clahe_filter = true;

secA = secs{1};
secA.img = imread(secA.filepath);

% Make grid
[gridX, gridY] = meshgrid(grid_sz:grid_sz:size(secA.img, 1), grid_sz:grid_sz:size(secA.img, 2));


for sec_num = 2:10
    secB = secs{sec_num};
    secB.img = imread(secB.filepath);
    
    ptsA = cell(1, 1);
    ptsB = cell(1, 1);
    for i = 1:size(gridX, 1)-2
        for j = 1:size(gridX, 2)-2
            % Get image data
            search_region = secA.img(gridX(i, j) - search_sz:gridX(i+1, j) + search_sz, gridY(i, j) - search_sz:gridY(i+1, j) + search_sz);
            block = secB.img(gridX(i, j):gridX(i+1, j), gridY(i, j):gridY(i+1, j));
            
            % World locations
            locA = [gridX(i, j) - search_sz, gridY(i, j) - search_sz];
            locB = [gridX(i, j), gridY(i, j)];
            
            % Cross correlation
            [ptA, ptB] = find_xcorr(search_region, locA, block, locB);
            
            % Save
            ptsA{end+1} = ptA;
            ptsB{end+1} = ptB;            
        end
    end
    
    % Merge points into matrix
    ptsA = vertcat(ptsA{:});
    ptsB = vertcat(ptsB{:});
    
    % Create match tables
    matches.A = table();
    matches.A.local_points = ptsA;
    matches.A.global_points = ptsA;
        
    matches.B = table();
    matches.B.local_points = ptsB;
    matches.B.global_points = ptsB;
          
    % Get metrics before filtering
    num_total_matches = height(matches.A);
    avg_total_error = rownorm2(matches.B.global_points - matches.A.global_points);
    
    % Calculate errors
    avg_error = rownorm2(matches.B.global_points - matches.A.global_points);
        
    % Add metadata
    matches.num_matches = height(matches.A);
    matches.meta.avg_error = avg_error;
    % matches.meta.avg_outlier_error = avg_outlier_error;
    matches.meta.avg_total_error = avg_total_error;
    % matches.meta.num_outliers = height(matches.outliers.A);
    matches.meta.num_total_matches = num_total_matches;
    
    secs{sec_num}.blockcorr_matches = matches;
    secA = secB;
end

clear('secA');

%% Save secs
filename = [folder '_blockcorr.mat'];
save(filename, 'secs', '-v7.3');

%% Prepare blockcorr matches
for i=2:10
    secs{i}.blockcorr_matches.outliers.A = table();
    secs{i}.blockcorr_matches.outliers.B = table();
    matches = secs{i}.blockcorr_matches;
    
    indexed_matches = dataset();
    indexed_matches.id = [1:height(matches.A)]';
    indexed_matches.localA = matches.A.local_points;
    indexed_matches.localB = matches.B.local_points;
    indexed_matches.globalA = matches.A.global_points;
    indexed_matches.globalB = matches.B.global_points;
    
    indexed_matches.dx = indexed_matches.localB(:, 1) - indexed_matches.localA(:, 1);
    indexed_matches.dy = indexed_matches.localB(:, 2) - indexed_matches.localA(:, 2);
    indexed_matches.dist = sqrt(indexed_matches.dy.^2 + indexed_matches.dx.^2);
    
    a = indexed_matches(indexed_matches.dist > 20, :);
    id_list = a.id;
    secs{i}.blockcorr_matches = remove_matches_by_id(secs{i}.blockcorr_matches, id_list);
end

%% Plot quivers and contours
for i=2:2
    figure()
    plot_matches_vectors(secs{i}.blockcorr_matches);
    plot_matches_contours(secs{i}.blockcorr_matches);
end

%% Make matches dataset
i = 2;
% matches = secs{i}.blockcorr_matches.outliers;
matches = secs{i}.blockcorr_matches;
indexed_matches = dataset();
indexed_matches.id = [1:height(matches.A)]';
indexed_matches.localA = matches.A.local_points;
indexed_matches.localB = matches.B.local_points;
indexed_matches.globalA = matches.A.global_points;
indexed_matches.globalB = matches.B.global_points;

indexed_matches.dx = indexed_matches.localB(:, 1) - indexed_matches.localA(:, 1);
indexed_matches.dy = indexed_matches.localB(:, 2) - indexed_matches.localA(:, 2);
indexed_matches.dist = sqrt(indexed_matches.dy.^2 + indexed_matches.dx.^2);


%% Show matches
a = indexed_matches(indexed_matches.dist > 6, :);
[s, idx] = sort(a.dist, 'descend');
mov = imshow_matches_external_images(secs{i-1}, secs{i}, a(idx, :), 1.0);
