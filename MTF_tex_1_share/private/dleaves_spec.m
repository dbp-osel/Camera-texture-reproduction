%% Program to return the 1-D power spectrum of the input image
% I - input 2-D image
% spec_inp - the output 1-D PSD
% freq - the frequency associated with the power spectrum

function [ spec_inp,freq ] = dleaves_spec( I )

[nrow, ncol, ~] = size(I);
n_min = min(nrow, ncol);
I = I(1:n_min, 1:n_min); %make it square so that we can calculate 1-D PSD

I_fft = abs(fft2(I));

% Use the second quadrant
%    2 | 1
%    -----
%    3 | 4
% Extract the required region
% +1 to extract the Nyquist frequency point also

I_fft = I_fft(1:fix((n_min+1)/2),1:fix((n_min+1)/2));

% Calculate 2-D spectrum
% Divide by n_min^2 since 2-D
spec_2d =(1/n_min^2)*(I_fft.^2);

%Radial averaging to get 1-D spectrum
[ spec_inp, freq ] = radial_avg(spec_2d); 
end

