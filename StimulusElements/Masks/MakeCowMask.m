function [MaskIm,mNew,nNew]=MakeCowMask(xsize,ysize,filtVal,con)
% function [MaskIm,mNew,nNew]=MakeCowMask(xsize,ysize,filtVal,con)
% returns mask image made of cowhide
% xsize and ysize give image dimensions, filtVal determines the max val of spatial filtering (cyc/pix), con the contrast (0-1) 
% eg [mask,mNew,nNew]=MakeCowMask(400,200,7,0.75); imshow(mask);

if ~exist('con')
    con=1;
end

TexSize = max([xsize ysize]); %take biggest size and make a square texture

noise   = randn(TexSize,TexSize); %noise    = noiseonf([Nsize Nsize],1); 

ImageFT   = fft2(noise);
ImageAng  = fftshift(angle(ImageFT));
ImagePow  = fftshift(abs(ImageFT));

[Xbig,Ybig] = meshgrid(linspace(0,TexSize-1,TexSize)-TexSize/2,linspace(0,TexSize-1,TexSize)-TexSize/2);
dist        = sqrt(Xbig.^2+Ybig.^2);
FiltRange   = (dist<filtVal);%exp(-(dist.^2)./(2*FilterSd^2));
ImagePow    = ImagePow.*FiltRange;

ImageFT2 = fftshift(ImagePow.*cos(ImageAng)+ImagePow.*sin(ImageAng).*sqrt(-1));
cownoise = (real((ifft2(ImageFT2))));

cownoise  = (cownoise./max(abs(All(cownoise))))./2; %range -0.5 to 0.5
cownoise  = round(cownoise+0.5); %range 0-1
cownoise  = 0.5+((cownoise-0.5).*con); %range 0-con
%cownoise  = round(cownoise./max(All(cownoise))); %range 0-con

MaskIm = single(cownoise(1:ysize,1:xsize));

%MaskIm = ImClip(MaskIm,[n+ceil(2*(RingRad+1)) m+ceil(2*(RingRad+1))]);
[nNew mNew] = size(MaskIm);
