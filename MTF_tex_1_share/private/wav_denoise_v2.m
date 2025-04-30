%% Function to perform wavelet denoising according to input parameters

function [ avg_tex ] = wav_denoise_v2( I,level,wname )

% Wavelet selection
[C,S]=wavedec2(I, level, wname);
% Threshold selection and denoising
thr = wthrmngr('dw2ddenoLVL','penallo',C,S,1.05);
sorh = 's'; % 's' - soft thresholding, 'h' - hard thresholding
[XDEN,~,~] = wdencmp('lvd',C,S,wname,level,thr,sorh);
avg_tex = double(XDEN);

end

