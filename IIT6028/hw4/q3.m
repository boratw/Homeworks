% hdr = hdrread('raw_gaussian_logarithm.hdr');
tic
% Constants
S = 0.2;
W = 5.;
sigma = [20, 1];


image_res = zeros(500, 750, 3);

% % RGB Tonemappig
% for c = 1:3
%     L_img = log(hdr(:, :, c));
%     B_img = bfilter2(L_img, W, sigma);
%     D_img = L_img - B_img;
%     B_img = (B_img - max(B_img(:))) .* S;
%     
%     I_tone = exp(D_img + B_img);
%     image_res(:, :, c) = I_tone(:, :);
% end
% 
% imwrite(image_res, 'RGB_S_0.5_W_5_sigma_3_0.5.png')

% % Get xyY image
% hdr_xyz = rgb2xyz(hdr, 'ColorSpace', 'srgb');
% hdr_xyY = zeros(500, 750, 3);
% hdr_xyY(:, :, 1) = hdr_xyz(:, : ,1) ./ (hdr_xyz(:, : ,1) + hdr_xyz(:, : ,2) + hdr_xyz(:, : ,3));
% hdr_xyY(:, :, 2) = hdr_xyz(:, : ,2) ./ (hdr_xyz(:, : ,1) + hdr_xyz(:, : ,2) + hdr_xyz(:, : ,3));
% hdr_xyY(:, :, 3) = hdr_xyz(:, : ,2);


% luminance Tonemapping
L_img = log(hdr_xyY(:, :, 3));
B_img = bfilter2(L_img, W, sigma);
D_img = L_img - B_img;
B_img = (B_img - max(B_img(:))) .* S;

I_tone = exp(D_img + B_img);

% Back to RGB image
image_res(:, :, 1) = I_tone(:, :) .* hdr_xyY(:, :, 1) ./ hdr_xyY(:, :, 2);
image_res(:, :, 2) = I_tone(:, :);
image_res(:, :, 3) = I_tone(:, :) .* (1 - hdr_xyY(:, :, 1) - hdr_xyY(:, :, 2)) ./ hdr_xyY(:, :, 2);

image_res = xyz2rgb(image_res);
imwrite(image_res, 'Lum_S_0.2_W_5_sigma_20_5.png')

toc