% CalibrateGammaBitSteal
%im=floor(LR.LtoVfun(LR,stim)); %sample call to extract correct values
%(once run)

thisFile='CalibrateGammaBitSteal.m';
ThisDirectory=which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));
%% setup

AssertOpenGL;
screens=Screen('Screens');
screenNumber=max(screens);
[w screenRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FillRect',w, [128 128 128]); % this is grey - in Mono++ the blue carries the LUT index
vbl=Screen('Flip', w);

%% first calibrate max range
%set B:R:G = 1:2:4
%max out blue guns and calibrate
%then set R to be twice that
%then G as twice again

m=256; n=256; p=3;                                  % Image dimensions
rgbImage=zeros(m,n,p,3);                              % This will be our stimulus
colindex = [3 1 2];%ie blue red green
for colgun=1:3 %test blue red green
    rgbImage(:,:,colindex(colgun),colgun)=rgbImage(:,:,colindex(colgun),colgun)+255;
    imText =Screen('MakeTexture', w, rgbImage(:,:,:,colgun));             % Make the image texture
    Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures
    vbl=Screen('Flip', w);
    MaxVal(colgun) = DefInput('Photometer Val?',0);
    Screen('Close',imText);
end
imText =Screen('MakeTexture', w, rgbImage(:,:,:,1).*0);             % Make the image texture
Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures
vbl=Screen('Flip', w);
MaxVal(colgun) = DefInput('Photometer Val?',0);
Screen('Close',imText);

%%

%
 m=256; n=256; p=3;                                  % Image dimensions
 rgbImage=zeros(m,n,p);                              % This will be our RGB stimulus

 NoSamps=16;
 V=linspace(0,2^8-1,NoSamps);
 tab1=repmat([1:256]',[1 3])./256;
 Screen('LoadNormalizedGammaTable', w, tab1,1);

 for cc=1:4 %each colour and then luminance
     for i=1:NoSamps
         rgbImage=zeros(m,n,p);                              % This will be our RGB stimulus
         RampImage=zeros(m,n)+V(i);
         if cc<4 %single colours
         rgbImage(:,:,cc)=RampImage;
         else
         rgbImage(:,:,1)=RampImage;
         rgbImage(:,:,2)=RampImage;
         rgbImage(:,:,3)=RampImage;
         end
         imText =Screen('MakeTexture', w, rgbImage);             % Make the image texture
         Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures
         vbl=Screen('Flip', w);
         L(cc,i) = CalLumInput('Enter luminance (cd/m2)',50);  % replace this with pause()
                 Screen('Close',imText);
     end
 end
 %L=[0.53 1.2 2.5 4.8 8.1 12.6 18 25 33.4 43 54 66.8 80 97 113 133];
 Screen('FillRect',w, [128 128 128]); % this is grey - in Mono++ the blue carries the LUT index
 vbl=Screen('Flip', w);

RGBvals = L(1:3,:); %just take RGB vals and ignore luminance 
RGBvals(:,1) = L(4,1)./3; %give all 3 the same black value equally distributed

LR=BitStealFitPower(V,RGBvals');
defFname=DefInput('Where to save calibration file? ',sprintf('%s%c',ThisDirectory,'BitStealCal3D.mat'));
save(defFname,'LR');

Screen('CloseAll')
