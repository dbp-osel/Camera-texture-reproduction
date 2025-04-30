%% Function for Acutance Calculation
% Summary: This program calculates the acutance, given a texture MTF.

% Initial conversion of the frequency necessary from f(cycles/pixel) to f (cycles/degree)
% d - viewing distance
% ph - picture height in units of distance (cm)
% n_ph - number of vertical pixels (along picture height)

function [ acu ] = acutance( texture_mtf, f_cy_pix, n_ph, d, ph )

switch nargin
    case 2
        n_ph = 965;
        d = 80;
        ph = 20;
end

%% Define CSF

f_cy_deg = f_cy_pix * (3.14 * n_ph * d)/(180*ph);

%Calculate CSF values at the above calculated frequencies
%CSF(v) = a.v^c.e^(-bv)/K

a = 25;
b = 0.2;
c = 0.8;
K = 34.05;

csf = zeros(1, length(f_cy_deg));
for i=1:length(f_cy_deg)
    csf(i) = (a*(f_cy_deg(i)^c)*exp(-b*f_cy_deg(i)))/K;
end


%% Acutance calculation

acutance_prod = zeros(1, length(texture_mtf));
for i=1:length(texture_mtf)
    acutance_prod(i) = texture_mtf(i)*csf(i);
end

acu = trapz(f_cy_deg,acutance_prod)/trapz(f_cy_deg,csf);

end

