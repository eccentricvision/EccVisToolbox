%MakeCowHideDemo

%% parameters and basis functions

Nsize   = 400; %noise size
Bsize   = 80; %gaussian blur size

aperture = DrawCirc(Nsize./2.25,[0 360],Nsize,Nsize);%GenerateGaussian(Nsize,Nsize,Nsize/8,Nsize/8,0,0,0);
apInd    = find(aperture==1);%(aperture./max(All(aperture)));

%% method 1 - blurring

noise   = noiseonf([Nsize Nsize],1); 
%noise   = randn(Nsize,Nsize);
gauss2d = GenerateGaussian(Bsize,Bsize,Bsize/6,Bsize/6,0,0,0);
bnoise  = conv2(noise,gauss2d,'same');
bnoise  = round(bnoise+0.5);
bnoise  = round(bnoise./max(All(bnoise))); %range 0-1

bnoise2  = ones(Nsize,Nsize)./2; %zeros(Nsize,Nsize);
bnoise2(apInd) = bnoise(apInd);

figure
imshow(bnoise2)

%% method 2 - SF filtering

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

bnoise2  = (bnoise2./max(abs(All(bnoise2))))./2; %range -0.5 to 0.5
bnoise2  = round(bnoise2+0.5);
bnoise2  = round(bnoise2./max(All(bnoise2))); %range 0-1
%bnoise2(bnoise2==0)=0.5; %no blacks - just bg luminance or white

bnoise3  = ones(Nsize,Nsize)./2; %zeros(Nsize,Nsize);
bnoise3(apInd) = bnoise2(apInd);
%bnoise2  = (bnoise2-0.5).*aperture;
%bnoise2  = (bnoise2./max(abs(All(bnoise2))))./2; %range -1 to 1
%bnoise2  = (bnoise2+0.5);

%Image2=double(mi+(ma-mi))*double(Image2-min(Image2(:)))./(max(Image2(:))-min(Image2(:)));%scale range
figure
imshow(bnoise3)

