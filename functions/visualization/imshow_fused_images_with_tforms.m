function imshow_fused_images_with_tforms(imgA, tformA, imgB, tformB)
% Show fused image of warped images

[warpA, refA] = imwarp(imgA, tformA);
[warpB, refB] = imwarp(imgB, tformB);
[M, refM] = imfuse(warpA, refA, warpB, refB);
imshow(M);