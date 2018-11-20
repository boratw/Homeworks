% hdr = hdrread('raw_gaussian_logarithm.hdr');
% 
ALPHA = 0.001;
BETA = 0.9;
% image_res = zeros(498, 748, 3);
% 
% % Get xyY image
% hdr_xyz = rgb2xyz(hdr, 'ColorSpace', 'srgb');
% hdr_xyY = zeros(500, 750, 3);
% hdr_xyY(:, :, 1) = hdr_xyz(:, : ,1) ./ (hdr_xyz(:, : ,1) + hdr_xyz(:, : ,2) + hdr_xyz(:, : ,3));
% hdr_xyY(:, :, 2) = hdr_xyz(:, : ,2) ./ (hdr_xyz(:, : ,1) + hdr_xyz(:, : ,2) + hdr_xyz(:, : ,3));
% hdr_xyY(:, :, 3) = hdr_xyz(:, : ,2);
% 
% % Gradiant Tonemapping
% L_img = log(hdr_xyY(:, :, 3));
% 
% % Make Gaussian Pyramid
% L_Gaussian = {};
% L_Gaussian{1} = L_img;
% [w, h] = size(L_img);
% i = 1;
% while((w > 5) && (h > 5))
%     x = imgaussfilt(L_Gaussian{i}, 2); % Gaussian Filtering
%     L_Gaussian{i + 1} = x(1:2:end, 1:2:end);
%     [w, h] = size(L_Gaussian{i+1});
%     i = i + 1;
% end

%Make phi (Gradient scale factor)
phi = zeros(4, 6);
for x = 1:4
    for y = 1:6
        if x == 1
            dif = (L_Gaussian{8}(x + 1, y) - L_Gaussian{8}(x, y)) ^ 2;
        elseif x == 4
            dif = (L_Gaussian{8}(x, y) - L_Gaussian{8}(x - 1, y)) ^ 2;
        else
            dif = (L_Gaussian{8}(x + 1, y) - L_Gaussian{8}(x - 1, y)) ^ 2;
        end
        if y == 1
            dif = dif + (L_Gaussian{8}(x, y + 1) - L_Gaussian{8}(x, y)) ^ 2;
        elseif y == 6
            dif = dif + (L_Gaussian{8}(x, y) - L_Gaussian{8}(x, y - 1)) ^ 2;
        else
            dif = dif + (L_Gaussian{8}(x, y + 1) - L_Gaussian{8}(x, y - 1)) ^ 2;
        end
        dif = sqrt(dif) * (2^(-8));
        if dif < 0.000001
            phi(x, y) = 3.;
        else
            phi(x, y) = (dif / ALPHA) ^ (BETA - 1.);
        end
    end
end
for i = 7:-1:1
    phi = imresize(phi, 2, 'bilinear');
    [w, h] = size(L_Gaussian{i});
    phi = phi(1:w, 1:h);
    for x = 1:w
        for y = 1:h
            if x == 1
                dif = (L_Gaussian{i}(x + 1, y) - L_Gaussian{i}(x, y)) ^ 2;
            elseif x == w
                dif = (L_Gaussian{i}(x, y) - L_Gaussian{i}(x - 1, y)) ^ 2;
            else
                dif = (L_Gaussian{i}(x + 1, y) - L_Gaussian{i}(x - 1, y)) ^ 2;
            end
            if y == 1
                dif = dif + (L_Gaussian{i}(x, y + 1) - L_Gaussian{i}(x, y)) ^ 2;
            elseif y == h
                dif = dif + (L_Gaussian{i}(x, y) - L_Gaussian{i}(x, y - 1)) ^ 2;
            else
                dif = dif + (L_Gaussian{i}(x, y + 1) - L_Gaussian{i}(x, y - 1)) ^ 2;
            end
            dif = sqrt(dif) * (2^(-i));
            if dif < 0.000001
                phi(x, y) = 3.;
            else
                phi(x, y) = phi(x, y) * ((dif / ALPHA) ^ (-0.1));
            end
        end
    end
end

% Normalize Phi
phi = phi / max(phi(:)) * 3;

im2var = zeros(498, 748, 'uint32');
im2var(1:498*748) = 1:498*748;

% Make G with scale factor
G = zeros(499, 749, 2);
for x = 1:499
    for y = 1:749
        G(x, y, 1) = phi(x, y) * (L_img(x + 1, y) - L_img(x, y));
        G(x, y, 2) = phi(x, y) * (L_img(x, y + 1) - L_img(x, y));
    end
end

% Make divG
divG = zeros(498*748 + 1, 1);
for x = 1:498
    for y = 1:748
        divG(im2var(x,y)) = G(x+1, y+1, 1) - G(x, y+1, 1) + G(x+1, y+1, 2) - G(x+1, y, 2);
    end
end
% Constant zero
divG(498*748 + 1) = 0.;
% 
% % Make Laplacian Matrix
% W = sparse(498*748+1, 498*748);
% for x = 1 : 498
%     for y = 1 : 748
%         i = 0;
%         if x ~= 1
%             W( im2var(x,y), im2var(x-1,y)) = 1;
%             i = i - 1;
%         end
%         if x ~= 498
%             W( im2var(x,y), im2var(x+1,y)) = 1;
%             i = i - 1;
%         end
%         if y ~= 1
%             W( im2var(x,y), im2var(x,y-1) ) = 1;
%             i = i - 1;
%         end
%         if y ~= 748
%             W( im2var(x,y), im2var(x,y+1) ) = 1;
%             i = i - 1;
%         end
%         W( im2var(x,y), im2var(x,y) ) = i;
%     end
% end
% % make center point to zero
% W(498*748+1, im2var(250,375)) = 1;

% solve equation
L_new = W \ divG;

% restore tone value
I_tone = zeros(498, 748);
I_tone(:) = exp(L_new);

% Normalize
I_tone = (I_tone - min(I_tone(:))) / (max(I_tone(:)) - min(I_tone(:)));

% Back to RGB image
image_res(:, :, 1) = I_tone(:, :) .* hdr_xyY(2:499, 2:749, 1) ./ hdr_xyY(2:499, 2:749, 2);
image_res(:, :, 2) = I_tone(:, :);
image_res(:, :, 3) = I_tone(:, :) .* (1 - hdr_xyY(2:499, 2:749, 1) - hdr_xyY(2:499, 2:749, 2)) ./ hdr_xyY(2:499, 2:749, 2);

image_res = xyz2rgb(image_res);
imwrite(image_res, 'Gradient_Tonemap_0.001_0.9_3.png')

