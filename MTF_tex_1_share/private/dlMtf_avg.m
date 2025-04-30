% Function to calculate the Texture MTF and the acutance for an image taken
% of the dead leaves target
% I_tex: image of the texture region
% I_noise: noise map
% opt: 0 --> no noise supression, I_noise is useless; 1 --> noise supression
% PSD_ref: 0 --> use theoretical ideal PSD; 1 --> use calculated matrix
% values

function [ f, tex_mtf, acu ] = dlMtf_avg( I_tex, I_noise, opt, PSD_ref )
% Load the PSD_ideal values as calculated using the Imatest target
% load('idealPSDvalues.mat'); %f_calcideal, PSD_calcideal

%% Preprocess input image and obtain grayscale image
%
% % Convert to grayscale double image, if required
% if size(I_tex,3)==3
%     I_tex = double(rgb2gray(I_tex));
% else
%     I_tex = double(I_tex);
% end
%
% if size(I_noise,3)==3
%     I_noise = double(rgb2gray(I_noise));
% else
%     I_noise = double(I_noise);
% end

% Crop to nearest power of 2, so that fft can be faster
I_tex = pow_crop(I_tex);
I_noise = pow_crop(I_noise);

% Obtain 1-D power spectrum of the input images
[spec_inp,f] = dleaves_spec(I_tex);
[spec_noise,~] = dleaves_spec(I_noise);

%%
% Obtain power spectrum of ideal input image, from loaded info
%  PSD_ref=0; % 0:calculated; 1:using ideal matrix

if PSD_ref==0
    [spec_ideal,f_ideal]=idealPSDCalc(I_tex);   
elseif PSD_ref==1
    load('idealPSDvalues.mat');
    % the mat file includes two vectors, frequency and spectrum. Genereated
    % based on the ImaTest results.
end

% Interpolate the calculated spectrums to match the range of PSD_ideal
spec_noise = interp1(f,spec_noise,f_ideal);
spec_inp = interp1(f,spec_inp,f_ideal);
f = f_ideal';
L1=find(f_ideal>=0.045,1);
L2=find(f_ideal>0.5,1);
%% Calculate the texture MTF

if opt==1
    tex_mtf = (spec_inp-spec_noise)./spec_ideal;
elseif opt==0
    tex_mtf = (spec_inp)./spec_ideal;
end

tex_mtf( tex_mtf<0 ) = 0;
tex_mtf = smooth_filt(sqrt(tex_mtf));

%% Limit to accurate range and normalize
% Normalize
tex_mtf=tex_mtf./tex_mtf(L1);
tex_mtf(1:L1)=1;
tex_mtf=tex_mtf(1:L2);
f=f(1:L2);
% Calculate acutance
acu = acutance(tex_mtf, f);

end

