%% Create random images
a = uint8(randi([0, 255], 300, 300));
tform = affine2d([cos(pi()/4) -sin(pi()/4) 0; sin(pi()/4) cos(pi()/4) 0; 0 0 1]);
aW = imwarp(a, tform);
aW_mask = imwarp(ones(size(a), 'uint8'), tform);
imshow(a)

%% Save TIFFs with Alpha Channels
aWM = repmat(aW,[1,1,2]);
aWM(:,:,2) = aW_mask;

%# create a tiff object
tob = Tiff('angled.tif', 'w');

%# you need to set Photometric before Compression
tob.setTag('Photometric',Tiff.Photometric.MinIsBlack)
tob.setTag('Compression',Tiff.Compression.None)

%# tell the program that channel 2 is alpha
tob.setTag('ExtraSamples',Tiff.ExtraSamples.Unspecified)

%# set additional tags (you may want to use the structure
%# version of this for convenience)
tob.setTag('ImageLength',size(aWM,1));
tob.setTag('ImageWidth',size(aWM,2));
tob.setTag('BitsPerSample',8);
tob.setTag('PlanarConfiguration',Tiff.PlanarConfiguration.Chunky);
tob.setTag('Software','MATLAB')
tob.setTag('SamplesPerPixel',2);

%# write and close the file
tob.write(aWM)
tob.close

imwrite(a, 'square.tif');