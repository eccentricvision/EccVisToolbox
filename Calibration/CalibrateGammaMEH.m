% CalibrateGamma
% function to calibrate the gamma of a CRT (achromatic)
% made by S Dakin, modified J Greenwood 2012


thisFile='CalibrateGamma.m';
ThisDirectory=which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));

BlackBG=1;
if BlackBG
    BGcol = [0 0 0];
else %grey BG
    BGcol = [128 128 128];
end

Use3Dmode = DefInput('Use 3D mode? 0/1',0); %0/1 for 3D mode e.g. on Asus VG278
blackout  = DefInput('Blackout main monitor? 0/1',0);

AssertOpenGL;
screens=Screen('Screens');

if numel(screens)>1
    if ispc
        blkScreen   = 3;
    else
        blkScreen = max(screens);
    end
    if blackout  %black out main monitor
        [w2 screenRect2]=Screen('OpenWindow',screens(blkScreen),0,[],32,2); %get Reference and resolution for main monitor
        blackim=zeros(screenRect2(3),screenRect2(4));
        Screen('FillRect',w2, [0 0 0]);
        Screen('Flip', w2);
    end
end

if IsWindows %use screen 1
    screenNumber=screens(1);%1;%max(screens);
else %use max screens
    screenNumber=max(screens);
end
if Use3Dmode
    [w screenRect]=Screen('OpenWindow',screenNumber, 0,[],32,2,1);%stereomode = 1 (shutters)
else
    [w screenRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);
end
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FillRect',w, BGcol);%[128 128 128]); % this is grey - in Mono++ the blue carries the LUT index
vbl=Screen('Flip', w);

if IsWindows %might need to hide the taskbar
    ShowHideWinTaskbarMex(0)
end

m=128; n=128; p=3;                                  % Image dimensions
rgbImage=zeros(m,n,p);                              % This will be our RGB stimulus

NoSamps=16;
V=linspace(0,2^8-1,NoSamps);
tab1=repmat([1:256]',[1 3])./256  ;
Screen('LoadNormalizedGammaTable', w, tab1,1);
% 
% for i=1:NoSamps
%     RampImage=zeros(m,n)+V(i);
%     rgbImage(:,:,1)=RampImage;
%     rgbImage(:,:,2)=RampImage;
%     rgbImage(:,:,3)=RampImage;
%     imText =Screen('MakeTexture', w, rgbImage);             % Make the image texture
%     Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures
%     vbl=Screen('Flip', w);
%     %L(i) = CalLumInput('Enter luminance (cd/m2)',50);  % replace this with pause()
%     pause();
%     Screen('Close',imText);
% end
 L=[0.18 0.41 1.39 3.40 6.22 10.3 16.7 25.8 37.2 51.8 69.1 89.7 111 145 180 222];
Screen('FillRect',w, BGcol);%[128 128 128]); % this is grey - in Mono++ the blue carries the LUT index
vbl=Screen('Flip', w);

%figure
LR=SimpleFitPower(V,L);
% 
% WhereRU  = DefInput('Where are you? 1=Lab 2=Office? 3=CinemaHD 4=Elsewhere',4);
% if WhereRU==1
%     fN = 'LabCalData.mat';
% elseif WhereRU==2
%     fN = 'OfficeCalData.mat';
% elseif WhereRU==3
%     fN = 'CinemaHDcaldata.mat';
% else
%     fN = 'CalData.mat';
% end
% defFname = DefInput('Where to save calibration file? ',sprintf('%s%c',ThisDirectory,fN));
% save(defFname,'LR')

linearLum=linspace(LR.LMin,LR.LMax,8);

for i=1:length(linearLum)
    theVoltage=floor(LR.LtoVfun(LR,linearLum(i)));
    rgbImage=theVoltage+0.*rgbImage;
    imText =Screen('MakeTexture', w, rgbImage);             % Make the image texture
    Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures
    vbl=Screen('Flip', w);
    Screen('Close',imText);
    %newL(i) = CalLumInput('Enter luminance (cd/m2)',50);  % replace this with pause()
    pause();
end
newL = [0.17 28.6 56.2 86.6 119 149 181 217];
 figure
 plot(linearLum,newL,'o',linearLum,linearLum,'-');
 Screen('CloseAll')

if IsWindows %might need to restore the taskbar
    ShowHideWinTaskbarMex(1)
end

