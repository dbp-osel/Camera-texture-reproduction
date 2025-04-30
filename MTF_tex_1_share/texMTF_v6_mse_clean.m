% Copyright (c) 2023, Quanzeng Wang
% This function generates a modulation transfer function (MTF) based on
% images of a 'dead leaves (DL)' target.  
% ------------------------------------------------------------------------
% The following paper should be cited in research results:
% N. Suresh, T. J. Pfefer, J. Su, Y. Chen, and Q. Wang, "Improved texture 
% reproduction assessment of camera-phone-based medical devices with a dead 
% leaves target," OSA Continuum, vol. 2, no. 6, pp. 1863-1879, 2019, 
% doi: https://doi.org/10.1364/OSAC.2.001863.
% ========================================================================
% FDA software disclaimer:
% This software and documentation (the "Software") were developed at the 
% Food and Drug Administration (FDA) by employees of the Federal Government 
% in the course of their official duties. Pursuant to Title 17, Section 105 
% of the United States Code, this work is not subject to copyright protection 
% and is in the public domain. Permission is hereby granted, free of charge, 
% to any person obtaining a copy of the Software, to deal in the Software 
% without restriction, including without limitation the rights to use, copy, 
% modify, merge, publish, distribute, sublicense, or sell copies of the 
% Software or derivatives, and to permit persons to whom the Software is 
% furnished to  do so. FDA assumes no responsibility whatsoever for use by 
% other parties of the Software, its source code, documentation or compiled
% executables, and makes no guarantees, expressed or implied, about its 
% quality, reliability, or any other characteristic. Further, use of this 
% code in no way implies endorsement by the FDA or confers any advantage in 
% regulatory decisions. 
% Although this software can be redistributed and/or modified freely, we ask 
% that any derivative works bear some notice that they are derived from it, 
% and any modified versions bear some notice that they have been modified.
% ========================================================================

%% Input program parameters
clear;clc;close all;

% Channel of the image to be analyzed.
channel=0; % 0:gray acale; 1:R; 2:G; 3:B.

% PSD of the target (i.e., the ground truth before being imaged):
PSD_ref=0; % 0:calculate PSD_ref based on the average of all captured images; 1:use the ideal PSD matrix directly.

wav_opt=1; % decide whether perform denoising with Wavelet Toolbox 
% '0' no wavelet thresholding denoising (one-step denoising)
% '1': Perform wavelet thresholding denoising (two-step denoising);

home = uigetdir('Images/','Select the folder containing images to process'); %folder with the images to be analyzed.
D=[...
    dir(fullfile(home,'*.TIFF'));
    dir(fullfile(home,'*.JPG'));
    dir(fullfile(home,'*.png'));
]; % structural array containing informaton for all the images.  

% noise_region=1; %1:texture; 2: gray_many images; 3:gray_one image
% The adding noise part of the codes has been replaced by the "cmos_noise_model_v1.m"
noise_add=0; %0: no added noise; 1: added Gaussion noise.
noise_mean=0; % 0-1
noise_sigma=0; % 0-255
noise_var=(noise_sigma/255)^2; % normalized noise variance (square of SD),0-1?

%% Read images and convert to suitable form

% N_img = 5; % Number of images to average
N_img=numel(D); % total # of images
imcell = cell(1,N_img); % a cell to store all images
for i=1:N_img
    imcell{i}=imread(strcat(home,'\',D(i).name));
end
[sz1,sz2,sz3]=size(imcell{1});

img_all=zeros(sz1,sz2,N_img);
if sz3==3
    if channel==0
        for i=1:N_img
            img_all(:,:,i)=rgb2gray(imcell{i});
        end
    else
        for i=1:N_img
            img_all(:,:,i)=imcell{i}(:,:,channel);
        end
    end
end

if sz3==1
    for i=1:N_img
        img_all(:,:,i)=imcell{i};
    end
end

%% Specify the locations of the gray region, and the texture region

disp('Follow the image window instruction');
image(imcell{1});
axis image  % set the aspect ratio to the image dimensions
title('Resize image for texture and gray region selection, then press Enter','Color', 'm');
zoom on;  % Zoom enabled
waitfor(gcf, 'CurrentCharacter', char(13));
zoom reset;
zoom off;

title('Click the upper-left and lower-right corners of the texture region');
p_tex = ginput(2); % (texture position) x1,y1:p_tex(1,1),p_tex(1,2); x2,y2:p_tex(2,1),p_tex(2,2)
% Obtain x & y coordinates
xmin = min(floor(p_tex(1)), floor(p_tex(2)));
ymin = min(floor(p_tex(3)), floor(p_tex(4)));
xmax = max(ceil(p_tex(1)), ceil(p_tex(2)));
ymax = max(ceil(p_tex(3)), ceil(p_tex(4)));
y_t = ymin:ymax;  % rows, texture
x_t = xmin:xmax; % columns, texture

title('click the upper-left and lower-right corners of the gray region');
p_gray = ginput(2);
% Obtain x & y coordinates
xmin = min(floor(p_gray(1)), floor(p_gray(2)));
ymin = min(floor(p_gray(3)), floor(p_gray(4)));
xmax = max(ceil(p_gray(1)), ceil(p_gray(2)));
ymax = max(ceil(p_gray(3)), ceil(p_gray(4)));
y_g = ymin:ymax; % rows, gray
x_g = xmin:xmax; % columns, gray

clear xmin ymin xmax ymax p_gray p_tex imcell;
%% Add noise if needed --> find the average image --> noise map

% Begin timer
tic;

% Add noise to images as needed, for testing purpose. 
if noise_add==1 
    img_all = double(imnoise(img_all,'Gaussian',noise_mean,noise_var));  % add noise to image, MATLAB command
% All numerical parameters are normalized— they correspond to operations with images with intensities ranging from 0 to 1
% https://www.mathworks.com/matlabcentral/answers/35547-imnoise-normalization
end

%% image denoising
% step 1: averaging
img_Avg = mean(img_all,3);

% step 2: wavelet-thresholding
tex_Avg = img_Avg(y_t,x_t);

if wav_opt==1 
    level=2;
    wname = 'coif5';
    tex_Avg_Wav=wav_denoise_v2(tex_Avg,level,wname);
end

%% Crop to obtain the gray patch from ONE of the images. This is used for 
% obtaining the DL-MTF according to McElvain et. al.

% Tile image to size of the texture region
gray_1st = img_all(y_g,x_g,1);
gray_1st = img_tile(gray_1st,y_t,x_t);
% gray_1st_sd = std(gray_1st(:));

% Extract the gray patch and the texture region from the average image
gray_Avg = img_Avg(y_g,x_g);
gray_Avg = img_tile(gray_Avg,y_t,x_t);
% gray_mean_sd = std(gray_mean(:));

% Further processing to obtain the noise-map
% Extract texture region from one of the captured images
% Can be looped to obtain the average over all images
tex_1st = img_all(y_t,x_t,1);
tex_noise = tex_1st-tex_Avg ; % noise map in the texture region
tex_noise_sd = std(tex_noise(:)); % noise sigmas in texture regions
if wav_opt==1
    tex_noise_wav = tex_1st-tex_Avg_Wav ; % noise map in the texture region
    tex_noise_wav_sd = std(tex_noise_wav(:)); % noise sigmas in texture regions
end

%% Additional MSE and PSNR calculation

% The MSE can be calculated from the mean image and one of the input images
[m,n]=size(tex_Avg);
MSE_Avg=sum(sum((tex_Avg-tex_1st).^2))/(m*n);
PSNR_Avg = 10*log10((255)^2/MSE_Avg);
if wav_opt==1
    MSE_Avg_Wav=sum(sum((tex_Avg_Wav-tex_1st).^2))/(m*n);
    PSNR_Avg_Wav = 10*log10((255)^2/MSE_Avg_Wav);
end

%% Calculate the DL-MTF using the Cao, McElvain (gray), and our proposed methods

[ f_cao, tex_mtf_cao, acu_cao ] = dlMtf_avg(tex_1st,gray_1st,0,PSD_ref); % Cao's method
[ f_gray, tex_mtf_gray, acu_gray ] = dlMtf_avg(tex_1st,gray_1st,1,PSD_ref); % McElvain's method
% [ f_prop, tex_mtf_prop, acu_prop ] = dlMtf_avg(tex_1st,tex_noise,1,PSD_ref); % Different from our proposed method that use denoised images directly.
[ f_Avg, tex_mtf_Avg, acu_Avg ] = dlMtf_avg(tex_Avg,tex_noise,0,PSD_ref); % tex_noise is useless
if wav_opt==1
    [ f_Avg_Wav, tex_mtf_Avg_Wav, acu_Avg_Wav ] = dlMtf_avg(tex_Avg_Wav,tex_noise,0,PSD_ref); % tex_noise is useless
end
% [ f_meangray, tex_mtf_meangray, acu_meangray ] = dlMtf_avg(tex_1st,gray_mean,1,PSD_ref);

%% Plot the calculated values

%End timer
toc;

figure;
fig=plot(f_cao,tex_mtf_cao,'-r');
hold on;
plot(f_gray,tex_mtf_gray,'-b');
plot(f_Avg,tex_mtf_Avg,'-.g');
if wav_opt==1
    plot(f_Avg_Wav,tex_mtf_Avg_Wav,'-g');
    legend('MTF_{DL-Cao}','MTF_{DL-gray}','MTF_{DL-den_{avg}}','MTF_{DL-den_{avg+wav}}');
else
    legend('MTF_{DL-Cao}','MTF_{DL-gray}','MTF_{DL-den_{avg}}');
end
axis([0.05 0.5 0 1.2]);
xlabel('Frequency (cycles/pixel)');
ylabel('MTF');
hold off;

% Compile result
tex_mtf_cao = tex_mtf_cao'; % Cao's method
tex_mtf_gray = tex_mtf_gray'; % McElvain's method
tex_mtf_Avg = tex_mtf_Avg';  % proposed method: averaging only
if wav_opt==1
    tex_mtf_Avg_Wav = tex_mtf_Avg_Wav'; % proposed method: averaging + wavelet
end
% tex_mtf_meangray = tex_mtf_meangray';

if wav_opt==1
    result = [f_cao,tex_mtf_cao,f_gray,tex_mtf_gray,f_Avg,tex_mtf_Avg,f_Avg_Wav,tex_mtf_Avg_Wav];
else
    result = [f_cao,tex_mtf_cao,f_gray,tex_mtf_gray,f_Avg,tex_mtf_Avg];
end

%% save figure and data
fname=datestr(clock,0); % Save parameters and results in a file
filename=strcat('outputs\',D(1).name(1:end-6),'_',fname(1:11),'_',fname(13:14),'-',fname(16:17),'-',fname(19:20));
saveas(fig,filename);
filename=strcat(filename,'.mat');
save(filename,'result');
