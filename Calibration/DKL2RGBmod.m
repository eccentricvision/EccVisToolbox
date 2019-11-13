function [rgb background] = DKL2RGB(dR,Lred,Lgreen,Lblue)
%function to convert a desired DKL vector into an RGB value for presentation
%need to input dR as [0.5 1 -0.5] for the L+M (luminance), L-M (red-green) and S-(L+M) (yellow-blue) axes
%also needs to receive the gamma corrected luminance profiles loaded from a
%monitor calibration file (e.g. OfficeCalDataRGB.mat) with separate profiles for the R G B guns
%
% based on code from Lu & Dosher (2014) Visual Psychophysics: From Laboratory to Theory. Display 5.11 (p150). 
% Implemented by J Greenwood Feb 2015.
%
% e.g. load('/Users/John/Documents/MATLAB/Calibration/MonitorData/OfficeCalDataRGB.mat');[rgb background] = DKL2RGB([0.2 0.2 0.75],Lred,Lgreen,Lblue); disp(rgb); disp(background);

%The following are chromaticity measurements at [0.5 0 0], [0 0.5 0], and [0 0 0.5]
x  = [Lred.chromaX Lgreen.chromaX Lblue.chromaX]; % xR xG xB
y  = [Lred.chromaY Lgreen.chromaY Lblue.chromaY]; % yR yG yB
L0 = [Lred.chromaL0 Lgreen.chromaL0 Lblue.chromaL0]'; % YR YG YB

gamma = [Lred.VtoLpow Lgreen.VtoLpow Lblue.VtoLpow]; %monitor gamma for the rgb guns
Lmin  = mean([Lred.LMin Lgreen.LMin Lblue.LMin]); %Y at rgb = [0 0 0];
Lmax  = [Lred.LMax Lgreen.LMax Lblue.LMax]; %Y at rgb = [1 0 0], [0 1 0], [0 0 1]

z = 1 - x - y; %zR zG zB (CIE coordinates?)

%Combine two 3x3 matrix in Eq 5.12
L2P = [0.15516 0.54308 -0.03287;
      -0.15516 0.45692  0.03287;
       0       0        0.01608] * ...
      [x ./ y;
       1 1 1;
       z ./ y];
   
P0 = L2P * L0; %compute background cone excitation (Eq. 5.12)

%conversion matrix (3x3) in Eq 5.17
DKL2dP = inv([1 1 1;
              1 -P0(1)/P0(2) 0;
             -1 -1 (P0(1)+P0(2))/P0(3)]);
         
%in Eq. 5.17, set [dRlum dRL_M dRS_lum] to [1 0 0], [0 1 0] and [0 0 1], respectively. 
%For each one, solve one of the constants based on CL^2 + CM^2 + CS^2 = 1.
kFactor = sqrt(sum((DKL2dP ./ (P0 * [1 1 1])) .^ 2))';

%Now convert DKL contrast dR (3x1) into normalised rgb
dP = DKL2dP * (dR' ./ kFactor); %Eq. 5.17
dL = inv(L2P) * dP; %Eq. 5.15

c = (1 + dL ./ L0) / 2; %convert to normalised rgb contrast

rgb = ((Lmax + Lmin) ./ (Lmax - Lmin) .* c') .^ (1 ./ gamma); %Eq 5.3
% for cc=1:3 %do one-by-one or else it produces imaginary numbers for all with -ve values taken to an exponent
%     ucval = abs(((Lmax(cc) + Lmin) ./ (Lmax(cc) - Lmin) .* c(cc)')); %take the absolute value here to avoid imaginary numbers?
%     rgb(cc) =  ucval .^ (1 ./ gamma(cc)); %Eq 5.3
% end

background = ((Lmax + Lmin) ./ (Lmax - Lmin) .* [0.5 0.5 0.5]) .^ (1./gamma);
          
