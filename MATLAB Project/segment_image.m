%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following code has been created for the Computer Vision 7CCSMCVI
% coursework for the year 2022-2023.
%  
% Student: Ciprian-Florin Ifrim - ID: 21202592
%
% The code employs the industry standard in image processing for edge
% detection, consisting in a conversion from RGB to back and white image,
% followed by the application of a DoG mask for better edges, in this case,
% great results were given by a difference of gaussians with curated values,
% to enchance the visibility of the edges in the image. From here, the
% image gets upscaled to 200%, in order to apply a 3x3 kernel for morphology
% (different sizes have been tested for best performance) through Matlab's
% "imerode" function. After the erosion, the image is downscaled back to 
% the original size, after which it is used together with the DoG blurred 
% image, to get the absolute values of their difference. This final image 
% is then passed to the Canny Edge detector with custom Threshold and Sigma
% values, to reduce noise and get more uniform contours.
% Then on the image with the edges, morphology thinning is performed to
% reduce the double line effect. 
% From here, I use Hough Circles to find all circles that are within 1 to 5
% pixels (after noticing a lot of circle noise present in the images) and
% then draw a filled black circle on top of them to remove the random white
% pixels resulting in noise.
%
% This process results in an average of 70.18% F1-Score over the 12 images
% provided for training. The F1 Score is 74% if the 3rd image is ignored.
%
% Most of the references used are official Matlab help pages:
% Absolute Diff: https://uk.mathworks.com/help/images/ref/imabsdiff.html
% Canny Edge: https://uk.mathworks.com/help/images/ref/edge.html
% DoG: https://en.wikipedia.org/wiki/Difference_of_Gaussians
% Thresholding: https://uk.mathworks.com/help/images/ref/imbinarize.html
% Morphology: https://uk.mathworks.com/help/images/morphological-filtering.html 
% Hough Circles: https://uk.mathworks.com/help/images/ref/imfindcircles.html
% Shapes: https://uk.mathworks.com/help/vision/ref/insertshape.html
% Morphology: https://uk.mathworks.com/help/images/ref/bwmorph.html
% 
% The rest of the references were taken from the exercises completed as
% part of the weekly Matlab tutorials of the course.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [seg] = segment_image(I)

% converion of the image to black and white from 3-channels (RGB)
image_bw = rgb2gray(I);

% Difference of Gaussian mask to enchance visible edges
dog_mask = fspecial('gaussian', 30, 1.25)-fspecial('gaussian', 30, 5.0);
image_dog = conv2(image_bw, dog_mask ,'same');

% Upscaling the DoG image by 2x for better
image_bw_upscaled = imresize(image_dog, 2, "bilinear");

% creating a 3x3 kernel (smallest) and applying it through erosion
kernel_morphology = [1 1 1; 1 1 1; 1 1 1];
image_eroded = imerode(image_bw_upscaled, kernel_morphology);

% downscaling back to the original size
image_close_downscaled = imresize(image_eroded, 0.5, "bilinear");

% subtracts each element in img1 from the corresponding element in img2
image_abs_diff = imabsdiff(image_dog, image_close_downscaled);

% This method uses two thresholds to detect strong and weak edges
image_canny = edge(image_abs_diff,'canny', 0.38, 0.46);

% This method perform  morphological thinning to reduce double lines
% generated by canny edge detector
image_morphology = bwmorph(image_canny ,'thin', Inf);

% Canny outputs a logical matrix, this converts it back to double precision
image_morphology = im2double(image_morphology);

% The Hough Circles code will give a warning for the selected Radius range
% of 1 to 5, stating that the algorithm will be less accurate, it is
% irrelevant, so it gets disabled
warning('off')

% The following code uses Hough Circles to remove little circles created by
% canny resulting in less noise in the final image
[centers, radii, ~] = imfindcircles(image_morphology,[1 5]);
image_circles_filtered = insertShape(image_morphology,'FilledCircle', ...
                              [centers radii], Color="black", Opacity=1.0); 

% the result from insertShape will be b&w because of the original image
% however outputted as 3 channels, we convert with rgb2gray
image_circles_filtered = rgb2gray(image_circles_filtered);

% set output of function to the image containing the detected edges
seg = image_circles_filtered;


