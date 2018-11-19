
function ret = getw(v)
%     ret = 1;
    if((v == 0) || (v == 255))
        ret = 0;
    else
       ret = exp(-((double(v) - 128.) ^ 2) / 4096);
    	ret = (128. - abs(double(v) - 128.)) / 128.;
        ret = 1;
   end
end

