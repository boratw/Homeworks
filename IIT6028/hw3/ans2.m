% % Read Image
img_back = imresize(imread('data/20180628_101201.jpg'), 0.25, 'bilinear');
img_obj = imresize(imread('data/1-551.jpg'), 0.25, 'bilinear');

% Get Align mask
objmask = getMask(img_obj);
[img_s, mask_s] = alignSource(img_obj, objmask, img_back);

img_back = double(img_back);
img_obj = double(img_obj);
img_source = img_back(201:353, 301:529, :);
imshow(img_source / 256.);

[height, width, chan] = size(img_obj);
grad_h = height - 2;
grad_w = width - 2;

% Make matrix
im2var = zeros(height, width, 'uint32');
im2var(1:height*width) = 1:height*width;
im2grad = zeros(grad_h, grad_w, 'uint32');
im2grad(1:grad_h*grad_w) = 1:grad_h*grad_w;
A = zeros(grad_h*grad_w, height*width);
b1_r = zeros(grad_h*grad_w, 1);
b1_g = zeros(grad_h*grad_w, 1);
b1_b = zeros(grad_h*grad_w, 1);
b2_r = zeros(grad_h*grad_w, 1);
b2_g = zeros(grad_h*grad_w, 1);
b2_b = zeros(grad_h*grad_w, 1);
b3_r = zeros(grad_h*grad_w, 1);
b3_g = zeros(grad_h*grad_w, 1);
b3_b = zeros(grad_h*grad_w, 1);
b4_r = zeros(grad_h*grad_w, 1);
b4_g = zeros(grad_h*grad_w, 1);
b4_b = zeros(grad_h*grad_w, 1);
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
            
                        
            b1_r(im2grad(y-1, x-1)) = grad_s(1);
            b1_g(im2grad(y-1, x-1)) = grad_s(2);
            b1_b(im2grad(y-1, x-1)) = grad_s(3);

            b2_r(im2grad(y-1, x-1)) = grad_s(1) * 0.75 + grad_t(1) * 0.25;
            b2_g(im2grad(y-1, x-1)) = grad_s(1) * 0.75 + grad_t(1) * 0.25;
            b2_b(im2grad(y-1, x-1)) = grad_s(1) * 0.75 + grad_t(1) * 0.25;
            
            b3_r(im2grad(y-1, x-1)) = grad_s(1) * 0.5 + grad_t(1) * 0.5;
            b3_g(im2grad(y-1, x-1)) = grad_s(2) * 0.5 + grad_t(2) * 0.5;
            b3_b(im2grad(y-1, x-1)) = grad_s(3) * 0.5 + grad_t(3) * 0.5;
            
            
            if abs(mean(grad_s)) > abs(mean(grad_t))
                b4_r(im2grad(y-1, x-1)) = grad_s(1);
                b4_g(im2grad(y-1, x-1)) = grad_s(2);
                b4_b(im2grad(y-1, x-1)) = grad_s(3);
            else
                b4_r(im2grad(y-1, x-1)) = grad_t(1);
                b4_g(im2grad(y-1, x-1)) = grad_t(2);
                b4_b(im2grad(y-1, x-1)) = grad_t(3);
            end
        else
            A(im2grad(y-1, x-1), im2var(y, x)) = 1;
            b1_r(im2grad(y-1, x-1)) = img_source(y, x, 1);
            b1_g(im2grad(y-1, x-1)) = img_source(y, x, 2);
            b1_b(im2grad(y-1, x-1)) = img_source(y, x, 3);
            
            b2_r(im2grad(y-1, x-1)) = img_source(y, x, 1);
            b2_g(im2grad(y-1, x-1)) = img_source(y, x, 2);
            b2_b(im2grad(y-1, x-1)) = img_source(y, x, 3);
            
            b3_r(im2grad(y-1, x-1)) = img_source(y, x, 1);
            b3_g(im2grad(y-1, x-1)) = img_source(y, x, 2);
            b3_b(im2grad(y-1, x-1)) = img_source(y, x, 3);
            
            b4_r(im2grad(y-1, x-1)) = img_source(y, x, 1);
            b4_g(im2grad(y-1, x-1)) = img_source(y, x, 2);
            b4_b(im2grad(y-1, x-1)) = img_source(y, x, 3);
        end
    end
end
% Get result
v_r = A \ b1_r;
v_g = A \ b1_g;
v_b = A \ b1_b;
vimg_r = reshape(v_r, height, width);
vimg_g = reshape(v_g, height, width);
vimg_b = reshape(v_b, height, width);

% Copy to Original Image
for y = 2:height-1
    for x = 2:width-1
        if objmask(y, x)
            img_back(y+200, x+300, 1) = vimg_r(y,x);
            img_back(y+200, x+300, 2) = vimg_g(y,x);
            img_back(y+200, x+300, 3) = vimg_b(y,x);
        end
    end
end

imwrite(img_back / 256, 'res/own1_s100.png');


% Get result
v_r = A \ b2_r;
v_g = A \ b2_g;
v_b = A \ b2_b;
vimg_r = reshape(v_r, height, width);
vimg_g = reshape(v_g, height, width);
vimg_b = reshape(v_b, height, width);

% Copy to Original Image
for y = 2:height-1
    for x = 2:width-1
        if objmask(y, x)
            img_back(y+200, x+300, 1) = vimg_r(y,x);
            img_back(y+200, x+300, 2) = vimg_g(y,x);
            img_back(y+200, x+300, 3) = vimg_b(y,x);
        end
    end
end

imwrite(img_back / 256, 'res/own1_s75.png');


% Get result
v_r = A \ b3_r;
v_g = A \ b3_g;
v_b = A \ b3_b;
vimg_r = reshape(v_r, height, width);
vimg_g = reshape(v_g, height, width);
vimg_b = reshape(v_b, height, width);

% Copy to Original Image
for y = 2:height-1
    for x = 2:width-1
        if objmask(y, x)
            img_back(y+200, x+300, 1) = vimg_r(y,x);
            img_back(y+200, x+300, 2) = vimg_g(y,x);
            img_back(y+200, x+300, 3) = vimg_b(y,x);
        end
    end
end

imwrite(img_back / 256, 'res/own1_s50.png');


% Get result
v_r = A \ b4_r;
v_g = A \ b4_g;
v_b = A \ b4_b;
vimg_r = reshape(v_r, height, width);
vimg_g = reshape(v_g, height, width);
vimg_b = reshape(v_b, height, width);

% Copy to Original Image
for y = 2:height-1
    for x = 2:width-1
        if objmask(y, x)
            img_back(y+200, x+300, 1) = vimg_r(y,x);
            img_back(y+200, x+300, 2) = vimg_g(y,x);
            img_back(y+200, x+300, 3) = vimg_b(y,x);
        end
    end
end

imwrite(img_back / 256, 'res/own1_max.png');

