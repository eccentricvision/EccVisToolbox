%MakeCowHideDemo

%% parameters and basis functions
clear all;

Nsize   = 2560; %noise size
Ysize   = 1440; %to be cropped later
Bsize   = 200; %gaussian blur size

UseColour = 1;

if ~UseColour
    ImCon   = 0.15;
else
    colCal='/Users/john.greenwood/Documents/MATLAB/Calibration/MonitorData/OfficeCalDataRGB.mat';
    load(colCal);
    
    HueDir = 258; %251 nice blue; %255 deeper blue; 258 almost purple; 100 nice green; 90 a deeper green; 60 nice coral; 70 redder, 75 more rusty; 80 maybe burnt umber; 85 brown; 266 purple
    ColCon = 0.2;
    LumCon = [-1 1].*0.2;
    [LMval,Sval] = pol2cart(-deg2rad(HueDir),ColCon);
    
    for lum=1:2
        CowCols(lum,:,:) = DKL2RGB([LumCon(lum) LMval Sval],Lred,Lgreen,Lblue);
    end
    CowCols = round(real(CowCols)*255)./255; %divide by 255 for screen presentation
    CowCols(CowCols<0)=0;
    CowCols(CowCols>1)=1;
    %    CowCols =  [0 196 197;24 215 218];%dark blue then light blue
end

%noise    = noiseonf([Nsize Nsize],1);
noise   = randn(Nsize,Nsize);

ImageFT   = fft2(noise);
ImageAng  = fftshift(angle(ImageFT));
ImagePow  = fftshift(abs(ImageFT));

[Xbig,Ybig] = meshgrid(linspace(1,Nsize,Nsize)-Nsize/2,linspace(1,Nsize,Nsize)-Nsize/2);
dist        = sqrt(Xbig.^2+Ybig.^2);
FiltRange   = (dist<Bsize);%exp(-(dist.^2)./(2*FilterSd^2));
ImagePow    = ImagePow.*FiltRange;

ImageFT2=fftshift(ImagePow.*cos(ImageAng)+ImagePow.*sin(ImageAng).*sqrt(-1));
bnoise2=(real((ifft2(ImageFT2))));
bnoise2  = (bnoise2./max(abs(All(bnoise2))))./2; %range -0.5 to 0.5
bnoise2  = round(bnoise2+0.5);

if ~UseColour
    bnoise2  = round(bnoise2./max(All(bnoise2)))-0.5; %range 0-1 then adjust back to -0.5 to 0.5
    bnoise3  = 0.5+(bnoise2*ImCon);
else
    for cc=1:3
        temp = bnoise2;
        temp(bnoise2==0)=CowCols(1,cc);
        temp(bnoise2==1)=CowCols(2,cc);
        bnoise3(:,:,cc) = temp; %./255 If not done above
    end
end

bnoise3=bnoise3(1:Ysize,:,:); %crop y dimension

figure
imshow(bnoise3)


imwrite(bnoise3,'/Users/john.greenwood/Desktop/CowHideBG.jpg','Quality',100); %save

