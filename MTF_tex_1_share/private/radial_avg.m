%% RADIAL_AVG This function radially averages a 2D function, and returns the
% averaged 1-D plot as the output
% inp_mat: 2-D matrix to be converted to 1-D

function [ binsum, freq ] = radial_avg( inp_mat )

[M,N]=size(inp_mat);  % M=N

% Create a grid of points which represent the distances from the origin and
% normalize
[X, Y]=meshgrid(0:M-1,0:N-1);
dist_mat = sqrt(X.^2 + Y.^2);
dist_mat =round(dist_mat); 
max_dist = max(dist_mat(:));

binsum=zeros(1,max_dist+1); % one for zero distance
bincount=zeros(1,max_dist+1);

for i=1:M
    for j=1:N
        index = dist_mat(i,j)+1;      
        binsum(index) = binsum(index) + inp_mat(i,j);
        bincount(index) = bincount(index) + 1;     
    end
end
% Calculate 1-D PSD
binsum=binsum./bincount;

% Specify frequency range
% Specify the pixel pitch and sampling rates
% p_pitch = 0.0043; % mm/px
% Fs = 1/p_pitch; % pixels/mm               
% % Compute the frequency increment
% dF = Fs/fix(max_dist); % cycles/mm
% dF = dF*p_pitch; % cy/px
% % Compute the frequency increment
% dF = Fs/fix(max_dist); % cycles/mm
% freq = (dF*(0:fix(max_dist)-1))/sqrt(2); 

dF = 1/max_dist; % frequency increment
freq = 0:dF:1;
freq = freq/sqrt(2); 
%at horizontal/vertical edges: 0.5 cycles/pixel
%at diagnal corner: sqrt(0.5^2+0.5^2)=1/sqrt(2).

val=min(length(freq),length(binsum));
freq=freq(1:val); binsum=binsum(1:val);
end

