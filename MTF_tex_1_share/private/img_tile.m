%% This function returns a tiled version of the input image
% tile - input image to be tiled
% a_t,b_t - dimension arrays given as input
% tiled_img - output tiled image

function [ tiled_img ] = img_tile( tile,a_t,b_t )

[m,n]=size(tile);

r_coeff = ceil(numel(a_t)/m);
c_coeff = ceil(numel(b_t)/n);

tiled_img = repmat(tile,r_coeff,c_coeff);

tiled_img = tiled_img(1:numel(a_t),1:numel(b_t));

end

