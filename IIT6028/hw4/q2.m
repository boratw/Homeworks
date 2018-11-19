% hdr = hdrread('raw_gaussian_logarithm.hdr');

% Constants
K = 0.35;
B = 0.001;

image_res = zeros(500, 750, 3);

% RGB Tonemappig
for c = 1:3
    I_org = hdr(:, :, c);
    I_m = exp( 1 / (500*750) * sum(log(I_org(:) + 1e-15)) );
    I_tilde = I_org * K / I_m;
    I_white = B * max(I_tilde(:));
    
    I_tone = I_tilde .* ( I_tilde ./ (I_white ^ 2)  + 1) ./ (I_tilde + 1);
    image_res(:, :, c) = I_tone(:, :);
end

imwrite(image_res, 'RGB_K_0.35_B_0.001.png')

% Get xyY image
hdr_xyz = rgb2xyz(hdr, 'ColorSpace', 'srgb');
hdr_xyY = zeros(500, 750, 3);
hdr_xyY(:, :, 1) = hdr_xyz(:, : ,1) ./ (hdr_xyz(:, : ,1) + hdr_xyz(:, : ,2) + hdr_xyz(:, : ,3));
hdr_xyY(:, :, 2) = hdr_xyz(:, : ,2) ./ (hdr_xyz(:, : ,1) + hdr_xyz(:, : ,2) + hdr_xyz(:, : ,3));
hdr_xyY(:, :, 3) = hdr_xyz(:, : ,2);


% luminance Tonemapping
I_org = hdr_xyY(:, :, 3);
I_m = exp( 1 / (500*750) * sum(log(I_org(:) + 1e-15)) );
I_tilde = I_org * K / I_m;
I_white = B * max(I_tilde(:));

I_tone = I_tilde .* ( I_tilde ./ (I_white ^ 2) + 1) ./ (I_tilde + 1);

% Back to RGB image
image_res(:, :, 1) = I_tone(:, :) .* hdr_xyY(:, :, 1) ./ hdr_xyY(:, :, 2);
image_res(:, :, 2) = I_tone(:, :);
image_res(:, :, 3) = I_tone(:, :) .* (1 - hdr_xyY(:, :, 1) - hdr_xyY(:, :, 2)) ./ hdr_xyY(:, :, 2);

image_res = xyz2rgb(image_res);
imwrite(image_res, 'Lum_K_0.35_B_0.001.png')
