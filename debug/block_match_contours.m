function block_match_contours(imgA, imgB)
% Generate grid of cross correlation contours for two images
% Fiddle with the internal parameters - fix it later

s = 0.175;

grid_sz = size(imgA, 1) / 32;
block_radius = 35;
search_radius = 35; % around block

startX = 1500;
endX = 6500;
startY = 2200;
endY = 7400;

show_images = true;

% Make grid
[gridX, gridY] = meshgrid(startX:grid_sz:endX, startY:grid_sz:endY);
wd = size(gridX, 1);
ht = size(gridX, 2);
n = 0;

figure('name', ['block_radius: ' num2str(block_radius) ', search_radius: ' num2str(search_radius)]);

for i = 1:size(gridX, 1)
    for j = 1:size(gridX, 2)
        x = gridX(i, j);
        y = gridY(i, j);
        A = imgA(y-search_radius : y+2*block_radius+search_radius, x-search_radius : x+2*block_radius+search_radius);
        B = imgB(y : y+2*block_radius, x : x+2*block_radius);

        c = normxcorr2(B, A);
        n = n + 1;
        subplot(wd, ht, n)
        o1 = size(B, 1);
        o2 = size(c, 1) - o1;
        C = c(o1:o2, o1:o2);
        
        [peakX, peakY, peakVal] = findpeak(c, false);
        
        % Calculate the offset of B from A
        offsetX = peakX - search_radius/2;
        offsetY = peakY - search_radius/2;
%         size(c(o1:o2, o1:o2))
        imshow(c(o1:o2, o1:o2))
        colormap hot
        colorbar
        axis on
        title([num2str(gridX(i,j)) ', ' num2str(gridY(i,j)), ': ' num2str(offsetX) ', ' num2str(offsetY) ', ' num2str(peakVal)])
    end
end

if show_images
    A = repmat(imgA, [1,1,3]);
    B = repmat(imgB, [1,1,3]);
    green = uint8([0 255 0]);
    shapeInserter = vision.ShapeInserter('Shape', 'Rectangles', 'Fill', true); %, 'BorderColor', 'Custom', 'CustomBorderColor', green);
    
    for i = 1:size(gridX, 1)
        for j = 1:size(gridX, 2)
            rect = int32([gridX(i, j)-search_radius gridY(i, j)-search_radius 2*block_radius+search_radius 2*block_radius+search_radius]);
            A = step(shapeInserter, A, rect);
        end
    end
    
    figure('name', 'imgA');
    imshow(A);
    axis on;
    
    rect = [];
    for i = 1:size(gridX, 1)
        for j = 1:size(gridX, 2)
            new_rect = int32([gridX(i, j) gridY(i, j) 2*block_radius 2*block_radius]);
            rect = [rect; new_rect];
        end
    end
    
    B = step(shapeInserter, B, rect);
    figure('name', 'imgB');
    imshow(B);
    axis on;
end