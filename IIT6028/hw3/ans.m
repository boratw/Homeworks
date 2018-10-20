% Read Image
img = imread('data/toy_problem.png');
[height, width, chan] = size(img);
img = double(img);

% height and width of gradiant image
grad_h = height - 1;
grad_w = width - 1;

im2var = zeros(height, width, 'uint32');
im2var(1:height*width) = 1:height*width;
im2grad = zeros(grad_h, grad_w, 'uint32');
im2grad(1:grad_h*grad_w) = 1:grad_h*grad_w;


A = zeros(grad_h*grad_w + 1, height*width);
b = zeros(grad_h*grad_w + 1, 1);
for y = 1 : height - 1
    for x = 1 : width - 1
        A(im2grad(y, x), im2var(y+1, x)) = -1;
        A(im2grad(y, x), im2var(y, x+1)) = -1;
        A(im2grad(y, x), im2var(y, x)) = 2;
        b(im2grad(y, x)) = 2 * img(y, x, 1) - ...
            img(y, x+1, 1) - img(y+1, x, 1);
    end
end
% image intensity of top left corner 
A(grad_h*grad_w + 1, im2var(1, 1)) = 1;
b(grad_h*grad_w + 1) = img(1,1,1);

v = A \ b;

% Write out the result
img_out = reshape(v, height, width, chan);
imwrite(img_out / 256., 'data/toy_problem_res.png');
