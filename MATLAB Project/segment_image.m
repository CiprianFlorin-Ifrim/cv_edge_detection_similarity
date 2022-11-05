%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following code has been created for the Computer Vision 7CCSMCVI
% coursework for the year 2022-2023.
%  
% Student: Ciprian-Florin Ifrim - ID: 21202592
%
% The code employs the industry standard in image processing for edge
% detection, consisting in a conversion from RGB to back and white image,
% followed by the application of a blurring mask, in this case, the best
% results were given by a difference of gaussians mask with curated values,
% to enchance the visibility of the edges in the image. From here, the
% image gets upscaled to 200%, in order to apply a 3x3 kernel for morphology
% (different sizes have been tested for best performance) through Matlab's
% "imerode" function. After the erosion, the image is downscaled back to 
% the original size, after which it is used together with the DoG blurred 
% image, to get the absolute values of their difference. This final image 
% is then passed to the Canny Edge detector with custom Threshold and Sigma
% values, to reduce noise and get more uniform contours.
%
% This process results in an average of 66% F1-Score over the 12 images
% provided for training.
%
% Most of the references used are official Matlab help pages:
% Abs Diff: https://uk.mathworks.com/help/images/ref/imabsdiff.html
% Canny Edge: https://uk.mathworks.com/help/images/ref/edge.html
% DoG: https://en.wikipedia.org/wiki/Difference_of_Gaussians
% Thresholding: https://uk.mathworks.com/help/images/ref/imbinarize.html
% Morphology: https://uk.mathworks.com/help/images/morphological-filtering.html 
%
% The rest of the references were taken from the exercises completed as
% part of the weekly Matlab tutorials of the course.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [seg] = segment_image(I)

% converion of the image to black and white from 3-channels (RGB)
image_bw = rgb2gray(I);

% Difference of Gaussian mask to enchance visible edges
dog = fspecial('gaussian',60,1.25)-fspecial('gaussian',60,3.0);
image_dog = conv2(image_bw,dog,'same');

% Upscaling the DoG image by 2x for better
image_bw_upscaled = imresize(image_dog, 2, "bilinear");

% creating a 3x3 kernel (smallest) and applying it through erosion
kernel_morphology = [1 1 1; 1 1 1; 1 1 1];
image_close = imerode(image_bw_upscaled, kernel_morphology);

% downscaling back to the original size
image_close_downscaled = imresize(image_close, 0.5, "bilinear");

% subtracts each element in img1 from the corresponding element in img2
image_abs_diff = imabsdiff(image_dog, image_close_downscaled);

% This method uses two thresholds to detect strong and weak edges
image_canny = edge(image_abs_diff,'canny', 0.37, 0.44);

% set output of function to the image containing the detected edges
seg = image_canny;


