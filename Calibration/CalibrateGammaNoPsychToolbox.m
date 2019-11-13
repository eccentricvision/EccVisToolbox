% CalibrateGammaNoFuckingPsychToolbox
%im=floor(LR.LtoVfun(LR,stim)); %sample call to extract correct values
%(once run)

thisFile='CalibrateGammaNoFuckingPsychToolbox.m';
ThisDirectory=which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));
 figure
 
m=128; n=128; p=3;                                  % Image dimensions
rgbImage=zeros(m,n,p);                              % This will be our RGB stimulus
 
NoSamps=16;
V=linspace(0,2^8-1,NoSamps);
tab1=repmat([1:256]',[1 3])./256  ;
%Screen('LoadNormalizedGammaTable', w, tab1,1);
 
    for i=1:NoSamps
        RampImage=zeros(m,n)+V(i);
        rgbImage(:,:,1)=RampImage;                      
        rgbImage(:,:,2)=RampImage;                  
        rgbImage(:,:,3)=RampImage;     
        imshow(rgbImage/255);
        L(i) = CalLumInput('Enter luminance (cd/m2)',50);  % replace this with pause()
    end
%L=[0.53 1.2 2.5 4.8 8.1 12.6 18 25 33.4 43 54 66.8 80 97 113 133];
 
figure(1) 
LR=SimpleFitPower(V,L);
defFname=DefInput('Where to save calibration file? ',sprintf('%s%c',ThisDirectory,'CalDataPsychMon.mat'));
save(defFname,'LR')

linearLum=linspace(LR.LMin,LR.LMax,8);

for i=1:length(linearLum)
        theVoltage=floor(LR.LtoVfun(LR,linearLum(i)));
        rgbImage=theVoltage+0.*rgbImage;
        imshow(rgbImage/255);
        newL(i) = CalLumInput('Enter luminance (cd/m2)',50);  % replace this with pause()
    end
figure(2) 
plot(linearLum,newL,'o',linearLum,linearLum,'-');
