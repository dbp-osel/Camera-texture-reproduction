%% IDEALPSDCALC 
% Function to obtain power spectrum of ideal input image
% Returns the spectrum according to the model proposed by McElvain et al.
% I_tex - the input image of texture region
% spec_orig - ideal theoretical PSD
% f - freq

function [ spec_orig,f ] = idealPSDCalc( I_tex )

m = size(I_tex,1);

if m < 256
    ln_A = 1.59; B = 2.295; C = 0.09991;
elseif m >= 256 && m< 512
    ln_A = 1.785; B = 2.400; C = 0.12613;
elseif m >= 512 && m < 1024
    ln_A = 1.976; B = 2.407; C = 0.12067;
elseif m >= 1024 && m < 2048
    ln_A = 2.131; B = 2.718; C = 0.19723;
else
    ln_A = 2.202; B = 3.601; C = 0.39951;
end

PSD_ideal=zeros(m,m);
imean = mean2(I_tex);

for u=1:m
    for v=1:m
        
        i=round(u-m/2);
        j=round(v-m/2);
        
        f_ideal = ( (i^2+j^2)^0.5 )/m ;
        
        
        if i==0 && j==0
            PSD_ideal(u,v)=(m^4)*(imean^2);    % Eq.1, McElvain et al.
            continue;
        end
        
        PSD_ideal(u,v) = exp( ln_A - B*log( f_ideal ) - C*((log(f_ideal))^2) );
        
    end
end

%% Radially average the PSD

lim = round((m+1)/2);
PSD_ideal=PSD_ideal(lim:end,lim:end);
[spec_orig,f] = radial_avg(PSD_ideal);

end

