video = VideoReader('2\\taewoo.mp4');
frames_rgb = {};
while hasFrame(video)
   frames_rgb{end+1} = readFrame(video);
end
framecount = size(frames_rgb, 2);
% convert frames to double-precision and range [0, 1]
frames_rgb = cellfun(@(x) double(x) ./ 256.0, frames_rgb, 'UniformOutput', false);
% convert frames to yiq color space
frames_yiq = cellfun(@(x) rgb2ntsc(x), frames_rgb, 'UniformOutput', false);

pyramid = cellfun(@LaplacianPyramid, frames_yiq, 'UniformOutput', false);
% pyramid : {1 x frame cell} {1 x level cell} (...)
pyramid = cat(1,pyramid{:});
% pyramid : {frame x level cell} (...)
pyramid = pyramid';
% pyramid : {level x frame cell} (...)
levelcount = size(pyramid, 1);

timeEachLevel = {};
for i = 1:levelcount
   timeEachLevel{end+1} = cat(4, pyramid{i,:});
end
% timeEachLevel : {1 x level cell} ( width x height x 3 x frames )

for i = 1:levelcount
   freqEachLevel = cellfun(@(x) fft(x, framecount, 4), timeEachLevel, ...
   'UniformOutput', false);
end

plotdata = [];
for i = 1:framecount
    m = 0;
	for j = 1:levelcount
        cell = freqEachLevel{j}(:, :, :, i);
        m = m + mean(abs(cell(:)));
	end
    plotdata = [plotdata; m];
end
plot(plotdata);
ylim([0, 1])

freqEachLevel_result = {};
band_a1 = 81; % left boundary of passing band
band_b1 = 81; % right boundary of passing band
band_a2 = framecount - band_b1 + 2;
band_b2 = framecount - band_a1 + 2;
amplifier = 300.0;

for i = 1:levelcount
    % Copy frequency domain for save the original images
    freqEachLevel_result{end + 1} = freqEachLevel{i}(:,:,:,:);
    % bandpass filtering and amplifying
    freqEachLevel_result{end}(:,:,:,band_a1:band_b1) = ...
        freqEachLevel_result{end}(:,:,:,band_a1:band_b1) .* amplifier;
    freqEachLevel_result{end}(:,:,:,band_a2:band_b2) = ...
        freqEachLevel_result{end}(:,:,:,band_a2:band_b2) .* amplifier;
end

for i = 1:levelcount
   timeEachLevel_result = cellfun(@(x) ifft(x, framecount, 4), freqEachLevel_result, ...
   'UniformOutput', false);
end

respyramid_tmp = cellfun(@(x) num2cell(x, [1 2 3]), timeEachLevel_result, ...
    'UniformOutput', false);
% respyramid_tmp : (1 x level cell} {1 x 1 x 1 x frame cell} (...)
respyramid = {};
for i = 1:framecount
    ret = {};
    
    for j = 1:levelcount
        ret{end+1} = respyramid_tmp{j}{1,1,1,i};
    end
    % ret : {1 x level cell} (...)
    respyramid{end+1} = ret;
end
% resppyraid : {1 x frame cell} {1 x level cell} (...)

resframes_yiq = cellfun(@InverseLaplacianPyramid, respyramid, 'UniformOutput', false);
resframes_rgb = cellfun(@ntsc2rgb, resframes_yiq, 'UniformOutput', false);
resvideo = VideoWriter('res\\taewoo_res_81_x100.mp4', 'MPEG-4');
open(resvideo)
for i = 1:framecount
   writeVideo(resvideo, resframes_rgb{i})
end
close(resvideo)

function ret = LaplacianPyramid(x)
    ret = {};
    [width, height, c] =  size(x);
    while((width > 1) || (height > 1))
        hx = imgaussfilt(x, 2); % Gaussian Filtering
        hx = hx(1:2:end, 1:2:end, :); % SubSampling
        % Upsampling (To make differance image)
        gx = imresize(hx, 2, 'nearest');
        % Take Differance and add to return cell
        ret{end+1} = x - gx(1:width, 1:height);
        x = hx;
        [width, height, c] =  size(x);
    end
    % Finally add 1x1 image to return cell
    ret{end+1} = x;
end


function ret = InverseLaplacianPyramid(x)
    % use real part only
    gx = real(x{size(x, 2)});
    for i = size(x, 2)-1:-1:1
        % UpSample
        gx = imresize(gx, 2, 'nearest');
        [width, height, c] =  size(x{i});
        gx = gx(1:width, 1:height);
        % Add Difference Image
        gx = gx + real(x{i});
    end
    ret = gx;
end
