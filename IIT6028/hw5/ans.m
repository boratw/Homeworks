img_plenoptic = imread('data/chessboard_lightfield.png');
lightfield = zeros(16, 16, 400, 700, 3);
for x = 1:400
    for y = 1:700
        for i = 1:16
            for j = 1:16
                for c = 1:3
                    lightfield(i, j, x, y, c) = double(img_plenoptic( (x - 1) * 16 + i, ...
                        (y - 1) * 16 + j, c)) / 256.;
                end
            end
        end
    end
end
img_mosaic = zeros(6400, 11200, 3);
for i = 1:16
    for j = 1:16
        img_mosaic( (i-1) * 400 + 1 : (i-1) * 400 + 400, (j-1) * 700 + 1 : (j-1) * 700 + 700, :) ...
            = lightfield(i, j, :, :, :);
    end
end
imwrite(img_mosaic, 'mosaic.png');
img_depth = {};
for d = 0:0.1:2
    img = zeros(400, 700, 3);
    for x = 1:400
        for y = 1:700
            sum = 0;
            for i = -7:8
                for j = -7:8
                    sx = round(x + i * d);
                    sy = round(y - j * d);
                    if sx >= 1 && sx <= 400 && sy >= 1 && sy <= 700
                        for c = 1:3
                            img(x, y, c) = img(x, y, c) + lightfield(i+8, j+8, sx, sy, c);
                        end
                        sum = sum + 1;
                    end
                end
            end
            img(x, y, :) = img(x, y, :) / sum;
        end
    end
    imwrite(img, strcat('img_depth_',num2str(d),'.png'));
    img_depth{end + 1} = img;
end
img_depth_lum = {};
img_depth_low = {};
img_depth_high = {};
img_depth_sharp = {};
for d = 1:21
    % Get luminance
    img_depth_lum{end + 1} = rgb2xyz(img_depth{d}, 'ColorSpace', 'srgb');
    img_depth_lum{end} = img_depth_lum{end}(:, :, 2);
    % Get low frequency
    img_depth_low{end + 1} = imgaussfilt(img_depth_lum{end}, 2);
    % Get high frequency
    img_depth_high{end + 1} = img_depth_lum{end} - img_depth_low{end};
    % Get sharpness
    img_depth_sharp{end + 1} = imgaussfilt(img_depth_high{end} .^ 2, 5);
end
img_all_focus = zeros(400, 700, 3);
img_depth_gray = zeros(400, 700);
 for x = 1:400
     for y = 1:700
        w = 0;
        for d = 1:21
            for c = 1:3
                img_all_focus(x, y, c) = img_all_focus(x, y, c) + img_depth{d}(x, y, c) * img_depth_sharp{d}(x, y);
            end
            img_depth_gray(x, y) = img_depth_gray(x, y) + d * img_depth_sharp{d}(x, y);
            w = w + img_depth_sharp{d}(x, y);
        end
        img_all_focus(x, y, :) = img_all_focus(x, y, :) / w;
        img_depth_gray(x, y) = img_depth_gray(x, y) / w;
     end
 end
imwrite(img_all_focus, 'img_all_focus.png');
imwrite(1. - img_depth_gray / 21, 'img_depth.png');