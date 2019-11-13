% CalibrateGammaBitSteal3Dmode
%im=floor(LR.LtoVfun(LR,stim)); %sample call to extract correct values
%(once run)
% Calibrate a monitor to use for bit stealing, but in 3D mode (e.g. Asus VG278HE)
% J Greenwood September 2014

thisFile='CalibrateGammaBitSteal.m';
ThisDirectory=which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));
%% setup
AssertOpenGL;
screens=Screen('Screens');

Use3Dmode = 1; %0/1 for 3D mode e.g. on Asus VG278
screenNumber=max(screens);

if Use3Dmode
    [w screenRect]=Screen('OpenWindow',screenNumber, 0,[],32,2,1); %stereomode =1 (shutters)
else
    [w screenRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);
end
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('Preference','SkipSyncTests',0); %Screen('Preference', 'VBLTimestampingMode', 0);
Screen('Preference', 'VBLEndlineOverride', 1125); %uses the VTotal value (from MonitorAssetManager using 1920x1080)

BlackBG=1;
if BlackBG
    BGcol = [0 0 0];
else %grey BG
    BGcol = [128 128 128];
end

if IsWindows %might need to hide the taskbar
    ShowHideWinTaskbarMex(0)
end

%% present some text to begin (first call to DefInput kills the onscreen texture for some reason)

Screen('FillRect',w, BGcol);
testIm = zeros(300,300,3)+255;
testTex = Screen('MakeTexture',w,testIm);
Screen('DrawTexture',w,testTex);
Screen('DrawText',w,'Calibration (hit enter to continue)',(screenRect(3)/2)-250,(screenRect(4)/2)-200,[255 255 255]);
vbl=Screen('Flip', w);

testIm = zeros(300,300,3);
testTex = Screen('MakeTexture',w,testIm);
Screen('DrawTexture',w,testTex);
Screen('DrawText',w,'Calibration (hit enter to continue)',(screenRect(3)/2)-250,(screenRect(4)/2)-200,[255 255 255]);
vbl=Screen('Flip', w,vbl+1);

testIm = zeros(300,300,3)+255;
testTex = Screen('MakeTexture',w,testIm);
Screen('DrawTexture',w,testTex);
Screen('DrawText',w,'Calibration (hit enter to continue)',(screenRect(3)/2)-250,(screenRect(4)/2)-200,[255 255 255]);
vbl=Screen('Flip', w,vbl+0.2);

waitTime = DefInput('Wait here til enter',0);

vbl=Screen('Flip', w,vbl+0.1);

%% first calibrate max range
%set B:R:G = 1:2:4
%max out blue guns and calibrate
%then set R to be twice that
%then G as twice again

m=256; n=256; p=3;                                  % Image dimensions
colindex = [3 1 2];%ie blue red green
for colgun=1:3 %test blue red green
    rgbImage=zeros(m,n,p);                              % This will be our stimulus
    rgbImage(:,:,colindex(colgun))=rgbImage(:,:,colindex(colgun))+255;
    imText =Screen('MakeTexture', w, rgbImage);             % Make the image texture
    
    %Screen('SelectStereoDrawBuffer', w, 0);%LE
    Screen('DrawTexture', w, imText);            % Draw all textures
    %Screen('SelectStereoDrawBuffer', w, 1);%RE
    %Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures
    
    vbl=Screen('Flip', w);
    MaxVal(colgun) = DefInput('Photometer Val?',0);
    
    Screen('Close',imText);
end
%now luminance
imText =Screen('MakeTexture', w, (rgbImage.*0)+255);             % Make the image texture - all ones/full

%Screen('SelectStereoDrawBuffer', w, 0);%LE
Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures
%Screen('SelectStereoDrawBuffer', w, 1);%RE
%Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures

vbl=Screen('Flip', w);
MaxVal(colgun) = DefInput('Photometer Val?',0);
Screen('Close',imText);

%% now cycle throught the whole luminance range

m=256; n=256; p=3;                                  % Image dimensions
rgbImage=zeros(m,n,p);                              % This will be our RGB stimulus

NoSamps=16;
V=linspace(0,2^8-1,NoSamps);
tab1=repmat([1:256]',[1 3])./256;
%Screen('LoadNormalizedGammaTable', w, tab1,1);

for cc=1:4 %each colour and then luminance (RGB L in order this time)
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
        
        %Screen('SelectStereoDrawBuffer', w, 0);%LE
        Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures
        %Screen('SelectStereoDrawBuffer', w, 1);%RE
        %Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures
        
        vbl=Screen('Flip', w);
        L(cc,i) = CalLumInput('Enter luminance (cd/m2)',50);  % enter input
        Screen('Close',imText);
    end
end
%L=[0.53 1.2 2.5 4.8 8.1 12.6 18 25 33.4 43 54 66.8 80 97 113 133];
Screen('FillRect',w, BGcol); % this is grey - in Mono++ the blue carries the LUT index
vbl=Screen('Flip', w);

RGBvals = L(1:3,:); %just take RGB vals and ignore luminance
RGBvals(:,1) = L(4,1)./3; %give all 3 the same black value equally distributed

LR=BitStealFitPower(V,RGBvals');
defFname = 'C:\Documents\MATLAB\Calibration\CalDataAsusVG278right3DmodeBitSteal.mat';%defFname=DefInput('Where to save calibration file? ',sprintf('%s%c',ThisDirectory,'BitStealCal3D.mat'));
save(defFname,'LR');

if IsWindows %might need to restore the taskbar
    ShowHideWinTaskbarMex(1)
end

Screen('CloseAll')
