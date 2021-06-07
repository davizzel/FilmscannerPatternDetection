%% Measures focus of the image according to Pech-Pacheco et al
% https://www.researchgate.net/publication/3887632_Diatom_autofocusing_in_brightfield_microscopy_A_comparative_study

% Load image
img = imread('/Documents/MATLAB/Filmscanner/Focus_testimages/Jawas.jpg');


% Convert image to grayscale
img_g = rgb2gray(img);
imshow(img_g);
%% Blur test image for validation

img_blurred = imread('/Documents/MATLAB/Filmscanner/Focus_testimages/Jawas_blurred.jpg');

img_g_blurred = rgb2gray(img_blurred);
imshow(img_g_blurred);

% Define convolution matrix:Laplacian matrix 
lm = [ 0 1 0; 1 -4 1; 0 1 0];

% Convolve image with laplacian matrix
c_img = conv2(img_g_blurred, lm);


% Calculate Tenengrad method of convolution
c_t = mean2(c_img.^2);

% Compare variance to custom threshold
th = 500;

if c_t < th
    disp('Image is blurry')
else
    disp('Image is sharp')
    
end
