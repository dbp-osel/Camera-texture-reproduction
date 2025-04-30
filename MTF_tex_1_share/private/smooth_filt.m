% SMOOTH_FILT Function to smooth the curve using a moving average filter
% x - input array to be averaged
% window - window size
% Default window is 5
% y - output averaged array

function [ y ] = smooth_filt( x ,window )

if nargin<2
    window=5;
end

if mod(window,2)==0
    window=window-1;
end

dw = floor(window/2);

y=x;

for i=dw+1:length(x)-dw
    y(i)=sum(x(i-dw:i+dw))/window;
end
  
end
