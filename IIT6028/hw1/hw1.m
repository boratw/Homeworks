% Q1. INITIALS
img = imread('data\\banana_slug.tiff');

cl = class(img);
reg = regexp(cl, '[0-9]');
bitPerInteger = str2num(cl(reg(1):1:end)); % Bit Per Integer
sz = size(img);
width = sz(2); % Width of Image
height = sz(1); % Height of Image
img = double(img); % Convert image into double-precision array

% Q2. LINEARIZATION
for i = 1:1:height
    for j = 1:1:width
        img(i, j) = (img(i, j) - 2047) / 12953;
        img(i, j) = max(min(img(i, j), 1), 0);
    end
end

% Q3. IDENTIFYING THE CORRECT BAYER PATTERN
im1 = img(1:2:end, 1:2:end); % left top part
im2 = img(1:2:end, 2:2:end); % right top part
im3 = img(2:2:end, 1:2:end); % left bottom part
im4 = img(2:2:end, 2:2:end); % right bottom part
% Assume rggb
im_rgb = cat(3, im1, im2, im4);
figure('Name', 'rggb Bayer Pattern');
imshow(min(1, im_rgb * 5));

% Q4. WHITE BALANCING
% white world white balancing
rmax = max(im1(:)); % Max value of R Channel
gmax = max(max(im2(:)), max(im3(:))); % Max value of G Channel
bmax = max(im4(:)); % Max value of B Channel

im1_wwb = im1 * gmax / rmax;
im2_wwb = im2;
im4_wwb = im4 * gmax / bmax;
im_rgb_wwb = cat(3, im1_wwb, im2_wwb, im4_wwb);
figure('Name', 'White World');
imshow(im_rgb_wwb);
figure('Name', 'White World 5x');
imshow(im_rgb_wwb * 5);

% gray world white balancing
rmean = mean(im1(:)); % Mean value of R Channel
gmean = (mean(im2(:)) + mean(im3(:))) / 2; % Mean value of G Channel
bmean = mean(im4(:)); % Mean value of R Channel

im1_gwb = im1 * gmean / rmean;
im2_gwb = im2;
im3_gwb = im3;
im4_gwb = im4 * gmean / bmean;
im_rgb_gwb = cat(3, im1_gwb, im2_gwb, im4_gwb);
figure('Name', 'Gray World');
imshow(im_rgb_gwb);
figure('Name', 'Gray World 5x');
imshow(im_rgb_gwb * 5);

% Q5. DEMOSAICING
[Xq, Yq] = meshgrid(1:1:width, 1:1:height);

imr_demosaic = interp2((1:2:width), (1:2:height), im1_gwb, Xq, Yq);
img_demosaic1 = interp2((2:2:width), (1:2:height), im2_gwb, Xq, Yq);
img_demosaic2 = interp2((1:2:width), (2:2:height), im3_gwb, Xq, Yq);
imb_demosaic = interp2((2:2:width), (2:2:height), im4_gwb, Xq, Yq);

img_demosaic = (img_demosaic1 + img_demosaic2) / 2;
img_demosaic(1:2:height, 2:2:width) = im2_gwb;
img_demosaic(2:2:height, 1:2:width) = im3_gwb;
im_rgb_demosaic = cat(3, imr_demosaic, img_demosaic, imb_demosaic);
figure('Name', 'Demosaic');
imshow(im_rgb_demosaic * 5);

%Q6. BRIGHTNESS ADJUSTMENT AND GAMMA CORRECTION
im_gray_demosaic = rgb2gray(im_rgb_demosaic);
percentage = 3.00;
%Display Brightness Adjusted Image
figure('Name', 'Gray');
imshow(im_gray_demosaic * percentage);

for i = 1:1:height
    for j = 1:1:width
        im_rgb_demosaic(i, j, 1) = GammaCorrection(im_rgb_demosaic(i, j, 1) * percentage);
        im_rgb_demosaic(i, j, 2) = GammaCorrection(im_rgb_demosaic(i, j, 2) * percentage);
        im_rgb_demosaic(i, j, 3) = GammaCorrection(im_rgb_demosaic(i, j, 3) * percentage);
    end
end
%Display Gamma Corrected Image
figure('Name', 'Corection');
imshow(im_rgb_demosaic);

%Q7. COMPRESSION
% PNG File (No Compression)
imwrite(im_rgb_demosaic, 'banana_slug.png')
% JPEG File (Quality 95)
imwrite(im_rgb_demosaic, 'banana_slug20.jpeg', 'Quality', 95)


function ret = GammaCorrection(value)
    if value <= 0.0031308
        ret = 12.92 * value;
    else
        ret =  min((1 + 0.055) * (value ^ (1 / 2.4)) - 0.055, 1.0);
    end
end
