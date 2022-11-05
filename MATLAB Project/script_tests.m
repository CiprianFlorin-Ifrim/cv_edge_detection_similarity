I = imread('Images/im1.jpg');
I = im2double(I);

image_bw = rgb2gray(I);

dog = fspecial('gaussian',60,1.25)-fspecial('gaussian',60,3.0);
image_dog = conv2(image_bw,dog,'same');


image_bw_upscaled = imresize(image_dog, 2, "bilinear");


kernel_morphology = [1 1 1; 1 1 1; 1 1 1];
image_close = imerode(image_bw_upscaled, kernel_morphology);


image_close_downscaled = imresize(image_close, 0.5, "bilinear");


image_abs_diff = imabsdiff(image_dog, image_close_downscaled);
image_abs_diff = imbinarize(image_abs_diff, 'global');


image_canny = edge(image_abs_diff,'canny', 0.23, 0.56);
image_canny = imfill(image_canny, 1);
image_canny = imcomplement(image_canny);



subplot(3,2,1); imagesc(I); colormap('default'); title('original')
subplot(3,2,2); imagesc(image_bw); colormap('gray'); title('image bw')
subplot(3,2,3); imagesc(image_dog); colormap('gray'); title('image dog')
subplot(3,2,4); imagesc(image_close_downscaled); colormap('gray'); title('image close')
subplot(3,2,5); imagesc(image_abs_diff); colormap('gray'); title('image abs diff')
subplot(3,2,6); imagesc(image_canny); colormap('gray'); title('image canny')