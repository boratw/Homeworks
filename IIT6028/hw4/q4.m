% hdr = hdrread('raw_gaussian_logarithm.hdr');
% 
ALPHA = 0.1;
BETA = 0.9;
% image_res = zeros(500, 750, 3);
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

% % Make phi
% phi = zeros(4, 6);
% for x = 2:3
%     for y = 2:5
%         dif =  sqrt((L_Gaussian{8}(x + 1, y) - L_Gaussian{8}(x - 1, y)) ^ 2 + (L_Gaussian{8}(x, y + 1) - L_Gaussian{8}(x, y-1)) ^ 2) / 2^(-8);
%         if dif < 0.001
%             phi(x, y) = 2.;
%         else
%             phi(x, y) = (dif / ALPHA) ^ (-0.1);
%         end
%     end
% end
% for i = 7:-1:1
%     phi = imresize(phi, 2);
%     [w, h] = size(L_Gaussian{i});
%     phi = phi(1:w, 1:h);
%     for x = 2:w-1
%         for y = 2:h-1
%             dif =  sqrt((L_Gaussian{i}(x + 1, y) - L_Gaussian{i}(x - 1, y)) ^ 2 + (L_Gaussian{i}(x, y + 1) - L_Gaussian{i}(x, y-1)) ^ 2) / 2^(-i);
%             if dif < 0.001
%                 phi(x, y) = phi(x, y) * 2.;
%             else
%                 phi(x, y) = phi(x, y) * (dif / ALPHA) ^ (-0.1);
%             end
%         end
%     end
% end

% % Make G
% G = zeros(500, 750, 2);
% for x = 1:500
%     for y = 1:750
%         if x ~= 500
%             G(x, y, 1) = phi(x, y) * (L_img(x + 1, y) - L_img(x, y));
%         end
%         if y ~= 750
%             G(x, y, 2) = phi(x, y) * (L_img(x, y + 1) - L_img(x, y));
%             end
%     end
% end
% 
% % Make divG
% divG = zeros(500*750, 1);
% for x = 2:500
%     for y = 2:750
%         divG((x-1) * 750 + y) = G(x, y, 1) - G(x-1, y, 1) + G(x, y, 2) - G(x, y-1, 2);
%     end
% end
% 

% Make Laplacian Matrix
W = sparse(500*750, 500*750);
for x = 2 : 499
    for y = 2 : 749
        W( (x-1) * 750, (x-1) * 750 + y ) = 4;
        W( (x-1) * 750, (x-2) * 750 + y ) = -1;
        W( (x-1) * 750, x * 750 + y ) = -1;
        W( (x-1) * 750, (x-1) * 750 + y - 1 ) = -1;
        W( (x-1) * 750, (x-1) * 750 + y + 1 ) = -1;
    end
end
    
% 
% % Back to RGB image
% image_res(:, :, 1) = I_tone(:, :) .* hdr_xyY(:, :, 1) ./ hdr_xyY(:, :, 2);
% image_res(:, :, 2) = I_tone(:, :);
% image_res(:, :, 3) = I_tone(:, :) .* (1 - hdr_xyY(:, :, 1) - hdr_xyY(:, :, 2)) ./ hdr_xyY(:, :, 2);
% 
% image_res = xyz2rgb(image_res);
% imwrite(image_res, 'Lum_S_0.3_W_1_sigma_5_1.png')

