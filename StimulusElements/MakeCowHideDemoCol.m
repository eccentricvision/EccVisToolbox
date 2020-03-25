%MakeCowHideDemoCol

%% parameters and basis functions

Nsize   = 400; %noise size
Bsize   = 80; %gaussian blur size

aperture = DrawCirc(Nsize./2.25,[0 360],Nsize,Nsize);%GenerateGaussian(Nsize,Nsize,Nsize/8,Nsize/8,0,0,0);
apInd    = find(aperture==1);%(aperture./max(All(aperture)));


%% colours

gamCal='/Users/john.greenwood/Documents/MATLAB/EccVisToolbox/Calibration/MonitorData/CalDataDiamondPlus.mat'; %the Gamma calibration file in the same directory (change this if it's elsewhere)
colCal='/Users/john.greenwood/Documents/MATLAB/EccVisToolbox/Calibration/MonitorData/CalDataDiamondPlusRGB.mat'; %the Gamma calibration file in the same directory (change this if it's elsewhere)

load(gamCal); %load gamma correction functions - LR
load(colCal); %load gamma correction for colour - Lred Lblue etc.

%get mgrey value
BGdkl = [0 0 0]; %0 luminance, 0 LMval, 0 Sval
mgrey    = round(DKL2RGB(BGdkl,Lred,Lgreen,Lblue)*255);

LumVals    = [-0.3 0.3]; %where e.g. Elcon is 0.5
HueAngle   = 262.5+5;
ColCon     = 0.2;

for lum = 1:numel(LumVals)
    [TarLMval(lum),TarSval(lum)] = pol2cart(-deg2rad(HueAngle),ColCon);
    TarCol(lum,:) = DKL2RGB([LumVals(lum) TarLMval(lum) TarSval(lum)],Lred,Lgreen,Lblue);
end

TarCol = round(real(TarCol)*255);
TarCol(TarCol<0)=0;
TarCol(TarCol>255)=255;

%% make the stimuli

%noise    = noiseonf([Nsize Nsize],1);
noise   = randn(Nsize,Nsize);

ImageFT   = fft2(noise);
ImageAng  = fftshift(angle(ImageFT));
ImagePow  = fftshift(abs(ImageFT));

[Xbig,Ybig] = meshgrid(linspace(1,Nsize,Nsize)-Nsize/2,linspace(1,Nsize,Nsize)-Nsize/2);
dist        = sqrt(Xbig.^2+Ybig.^2);
FiltRange   = (dist<5);%exp(-(dist.^2)./(2*FilterSd^2));
ImagePow    = ImagePow.*FiltRange;

ImageFT2=fftshift(ImagePow.*cos(ImageAng)+ImagePow.*sin(ImageAng).*sqrt(-1));
bnoise2=(real((ifft2(ImageFT2))));

bnoise2  = (round((bnoise2./max(abs(bnoise2(:)))./2)+0.5)-0.5)*2; %range -1 to 1
%cownoise  = (round((cownoise./max(abs(cownoise(:)))./2)+0.5)-0.5)*2; %gets values of either -1 or 1 - correct to actual contrast & luminance values later
                
cowcol = zeros(Nsize,Nsize,3)+0.5; %grey background
temp   = zeros(Nsize,Nsize,1)+0.5; %grey background
for col=1:3 %make RGB values for cownoise tarcol is set as sp.TarCol(dir,:,lum)
    temp(apInd) = bnoise2(apInd);
    temp(temp==-1)  = TarCol(1,col)./255;
    temp(temp==1)   = TarCol(2,col)./255;
    cowcol(:,:,col) = temp;
end

%bnoise3  = ones(Nsize,Nsize)./2; %zeros(Nsize,Nsize);
%bnoise3(apInd) = bnoise2(apInd);
%bnoise2  = (bnoise2-0.5).*aperture;
%bnoise2  = (bnoise2./max(abs(All(bnoise2))))./2; %range -1 to 1
%bnoise2  = (bnoise2+0.5);

%Image2=double(mi+(ma-mi))*double(Image2-min(Image2(:)))./(max(Image2(:))-min(Image2(:)));%scale range
figure
imshow(cowcol)

