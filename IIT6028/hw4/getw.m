
function ret = getw(v)
    if((v == 0) || (v == 255))
        ret = 0;
    else
        %select weighting function and uncomment one
        
        %ret = exp(-((double(v) - 128.) ^ 2) / 4096);
    	%ret = (128. - abs(double(v) - 128.)) / 128.;
        ret = 1;
   end
end

