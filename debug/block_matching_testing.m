%% Load images
imgA = imread('renders/S2-W001_Secs1-168_z/S2-W001_Sec1_Montage-z.tif');
imgB = imread('renders/S2-W001_Secs1-168_z/S2-W001_Sec2_Montage-z.tif');


%% Set parameters
scale = [0.20];
block_radius = [40:300:1300];
search_radius = [10:40:200];

%% Resize images
br = 220;
sr = 1;
% start = randi([3000 20000], 1)
start = 16343;

A = imgA(start-sr:start+2*br+sr, start-sr:start+2*br+sr);
B = imgB(start:start+2*br, start:start+2*br);

for s = scale
    reA = imresize(imgA, s);
    reB = imresize(imgB, s);
   
    base = imresize(A, s);
    template = imresize(B, s);
    
    figure('name', ['scale ' num2str(s)]);
    subplot(3, 2, 1)
    imshow(imgA);
    title('A')
    axis on
    subplot(3, 2, 2)
    imshow(imgB);
    title('B')
    axis on
    subplot(3, 2, 3)
    imshow(reA);
    title('scaled A')
    axis on
    subplot(3, 2, 4)
    imshow(reB);
    title('scaled B')
    axis on
    subplot(3, 2, 5)
    imshow(base);
    title('base')
    axis on
    subplot(3, 2, 6)
    imshow(template);
    title('template')
    axis on
end

%% Run correlation
wd = length(block_radius);
ht = length(search_radius);
random_start = randi([3000 20000], 1)

BR = [];
SR = [];
PV = [];
D = [];

for s = scale
    n = 0;
    figure('name', ['corr scale ' num2str(s)]);
    
    
    for start = random_start
        for sr = search_radius
            for br = block_radius
                
                A = imgA(start-sr:start+2*br+sr, start-sr:start+2*br+sr);
                B = imgB(start:start+2*br, start:start+2*br);
                
                base = imresize(A, s);
                template = imresize(B, s);
                
                c = normxcorr2(template, base);
                
                [peakX, peakY, peakVal] = findpeak(c, true);
                offsetX = peakX - (size(template, 2) + size(base, 2))/2
                offsetY = peakY - (size(template, 1) + size(base, 1))/2
                D(end+1) = norm([offsetX offsetY]);
                
                BR(end+1) = br;
                SR(end+1) = sr;
                PV(end+1) = peakVal;
                
                n = n + 1;
                subplot(ht, wd, n)
                o1 = int32((size(c, 1) - size(base, 1)) / 2);
                o2 = size(c, 1) - o1;
                imshow(c(o1:o2, o1:o2))
                colormap hot
                colorbar
                axis on
                title(['sr ' num2str(sr) ', br ' num2str(br)])
            end
        end
    end
end

%% Plot
figure
subplot(4, 1, 1)
plot(BR, PV, 'o')
xlabel('block radius')
ylabel('peak value (norm intensity)')
subplot(4, 1, 2)
plot(SR, PV, 'o')
xlabel('search radius')
ylabel('peak value (norm intensity)')
subplot(4, 1, 3)
plot(BR, D, 'o')
xlabel('block radius')
ylabel('offset (px)')
subplot(4, 1, 4)
plot(SR, D, 'o')
xlabel('search radius')
ylabel('offset (px)')


%% Mesh
figure
z = reshape(PV, [length(block_radius), length(search_radius)]);
mesh(search_radius, block_radius, z)
% imshow(z)
% colormap hot
% colorbar