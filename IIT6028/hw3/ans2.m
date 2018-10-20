% % Read Image
% img_back = imresize(imread('data/hiking.jpg'), 0.25, 'bilinear');
% img_obj = imresize(imread('data/penguin-chick.jpeg'), 0.25, 'bilinear');
% 
% % Get Align mask
% objmask = getMask(img_obj);
% [img_s, mask_s] = alignSource(img_obj, objmask, img_back);
% 
% img_back = double(img_back);
% img_obj = double(img_obj);
% img_source = img_back(326:450, 201:301, :);
% imshow(img_source / 256.);
% 
% [height, width, chan] = size(img_obj);
% grad_h = height - 2;
% grad_w = width - 2;

% Make matrix
im2var = zeros(height, width, 'uint32');
im2var(1:height*width) = 1:height*width;
im2grad = zeros(grad_h, grad_w, 'uint32');
im2grad(1:grad_h*grad_w) = 1:grad_h*grad_w;
A = zeros(grad_h*grad_w, height*width);
b_r = zeros(grad_h*grad_w, 1);
b_g = zeros(grad_h*grad_w, 1);
b_b = zeros(grad_h*grad_w, 1);
for y = 2:height-1
    for x = 2:width-1
        if objmask(y, x)
            A(im2grad(y-1, x-1), im2var(y, x)) = 4;
            A(im2grad(y-1, x-1), im2var(y-1, x)) = -1;
            A(im2grad(y-1, x-1), im2var(y, x-1)) = -1;
            A(im2grad(y-1, x-1), im2var(y+1, x)) = -1;
            A(im2grad(y-1, x-1), im2var(y, x+1)) = -1;
            grad_s = img_obj(y, x, :) * 4 - img_obj(y-1, x, :) - ...
                img_obj(y, x-1, :) - img_obj(y+1, x, :) - img_obj(y, x+1, :);
            grad_t = img_source(y, x, :) * 4 - img_source(y-1, x, :) - ...
                img_source(y, x-1, :) - img_source(y+1, x, :) - img_source(y, x+1, :);
            if abs(mean(grad_s)) > abs(mean(grad_t))
                b_r(im2grad(y-1, x-1)) = grad_s(1);
                b_g(im2grad(y-1, x-1)) = grad_s(2);
                b_b(im2grad(y-1, x-1)) = grad_s(3);
            else
                b_r(im2grad(y-1, x-1)) = grad_t(1);
                b_g(im2grad(y-1, x-1)) = grad_t(2);
                b_b(im2grad(y-1, x-1)) = grad_t(3);
            end
%             b_r(im2grad(y-1, x-1)) = img_obj(y, x, 1) * 4 - img_obj(y-1, x, 1) - ...
%                 img_obj(y, x-1, 1) - img_obj(y+1, x, 1) - img_obj(y, x+1, 1);
%             b_g(im2grad(y-1, x-1)) = img_obj(y, x, 2) * 4 - img_obj(y-1, x, 2) - ...
%                 img_obj(y, x-1, 2) - img_obj(y+1, x, 2) - img_obj(y, x+1, 2);
%             b_b(im2grad(y-1, x-1)) = img_obj(y, x, 3) * 4 - img_obj(y-1, x, 3) - ...
%                 img_obj(y, x-1, 3) - img_obj(y+1, x, 3) - img_obj(y, x+1, 3);
        else
            A(im2grad(y-1, x-1), im2var(y, x)) = 1;
            b_r(im2grad(y-1, x-1)) = img_source(y, x, 1);
            b_g(im2grad(y-1, x-1)) = img_source(y, x, 2);
            b_b(im2grad(y-1, x-1)) = img_source(y, x, 3);
        end
    end
end
% Get result
v_r = A \ b_r;
v_g = A \ b_g;
v_b = A \ b_b;
vimg_r = reshape(v_r, height, width);
vimg_g = reshape(v_g, height, width);
vimg_b = reshape(v_b, height, width);

% Copy to Original Image
for y = 2:height-1
    for x = 2:width-1
        if objmask(y, x)
            img_back(y+325, x+200, 1) = vimg_r(y,x);
            img_back(y+325, x+200, 2) = vimg_g(y,x);
            img_back(y+325, x+200, 3) = vimg_b(y,x);
        end
    end
end

imshow(img_back / 256.);

