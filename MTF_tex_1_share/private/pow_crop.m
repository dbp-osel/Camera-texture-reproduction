%% POW_CROP This function returns a cropped version of the input image,
% cropped to the nearest power of 2

function [ I_out ] = pow_crop( I_in )

I_in = double(I_in);

[m, n] = size(I_in);

if m>n
    m=n;
else
    n=m;
end

log_value = floor(log2(m));
I_out = I_in(1:2^log_value,1:2^log_value);


end

