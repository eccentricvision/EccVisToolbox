%CalibrateGammaBitSteal3Dverification
%show a luminance ramp and measure values of brightness to ensure it's correct
%setup for a 3D Asus VG278 monitor in 3D mode using Bit Stealing
%
%John Greenwood September 2014

clear all;
%% general  & input parameters

thisFile='CalibrateGammaBitSteal3Dverification.m';
ThisDirectory=which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));

BitsYN          = 0;%DefInput('Using the Bits#? (0=no, 1=yes)',0); %no to Bits++ Box
sp.WhereRU      = 1; %lab PC with three Asus monitors

%% setting up the screen and psychtoolbox

AssertOpenGL;
screens=Screen('Screens'); %the handle for each monitor present
%PsychImaging('PrepareConfiguration');

RightScreen = 1;% only the right screen is set up for bit stealing at present DefInput('Which Screen? 0=Left, 1=Right',1);

BGcol = [0 0 0];

switch sp.WhereRU
    case 1 %on the lab PC
        if RightScreen
            gamCal='C:\Documents\MATLAB\Calibration\CalDataAsusVG278right3DBitSteal.mat';
        else %LeftScreen
            gamCal='C:\Documents\MATLAB\Calibration\CalDataAsusVG278left3Dmode.mat';
        end
    otherwise %in the office
        gamCal='/Users/John/Documents/MATLAB/Calibration/CalData.mat'; %select Gamma calibration files
end
load(gamCal); %load gamma correction functions %im=floor(LR.LtoVfun(LR,stim)); %sample call to extract correct values

InitialiseBitSteal; %set up vLUT
mgrey  = BitStealVal(0.5,LR,vLUT); %mean grey value for bit stealing
minlum = BitStealVal(0,LR,vLUT); %min lum value
maxlum = BitStealVal(1,LR,vLUT); %max lum value

Screen('Preference','SkipSyncTests',0); %Screen('Preference', 'VBLTimestampingMode', 0);
StereoMode = 1; %alternating (0=no stereo, 7=Green/Red)

%now open the monitor window
[w screenRect]=Screen('OpenWindow',screens, 0,[],32,2,StereoMode); %max(Screens); %max(Screens)
%get monitor parameters
centX=screenRect(3)/2;
centY=screenRect(4)/2; %find the x/y centre of the screen

Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('TextFont', w, 'Arial');
Screen('TextSize', w, 36);

Screen('FillRect', w, BGcol);
Screen('Flip', w);

if IsWindows %might need to hide the taskbar
    ShowHideWinTaskbarMex(0)
end

%% screen/viewing parameters

sp.ScreenResX    = screenRect(3); %screen size in pixels
sp.ScreenResY    = screenRect(4);
sp.ScreenSizeX   = 59.8; %screen size in centimetres (measured for Asus VG278)
sp.ScreenSizeY   = 33.6;
sp.PixelScale    = mean([sp.ScreenSizeX./sp.ScreenResX sp.ScreenSizeY./sp.ScreenResY]);%0.035; %size of pixels in cm (take average of X/Y dimensions to assume square pixels- check!)
sp.ViewDist      = 60;%65;%57; %60 %70 %50; %viewing distance in cm

sp.BezelSize     = 2.2; %size of monitor bezel/edge in cm (2.2cm each with LED fixation due to gap, 2cm without)
sp.BezelPixels   = round(sp.BezelSize./sp.PixelScale); %how many pixels are hidden behind the bezel

%where to find the 'zero pos' = midpoint of both screens
sp.ZeroPosX    = centX; %right screen
sp.ZeroPosY    = centY;%980;%720;% 720];%[sp.ScreenResY-150 sp.ScreenResY-150];

%max eccentricity visible
sp.TotalVF      = PixToVA(sp.ViewDist,sp.PixelScale,(sp.ScreenResX)); %size of whole visual field
sp.MaxEcc       = sp.TotalVF/2;
sp.MaxPixDist   = sqrt((sp.ScreenResX^2)+(sp.ScreenResY^2)); %max possible line length (diagonal)

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

%% parameters and setup

displayableL=LR.VtoLfunR(LR,vLUT(:,1)')+LR.VtoLfunG(LR,vLUT(:,2)')+LR.VtoLfunB(LR,vLUT(:,3)');
LMax = max(displayableL);
LMin = min(displayableL);

linearLum=linspace(LMin,LMax,8);

m=128; n=128; p=3;                                  % Image dimensions

%% draw things

for i=1:length(linearLum)
    rgbImage=zeros(m,n,p);                              % This will be our RGB stimulus
    theVoltage = BitStealVal(linearLum(i)./LMax,LR,vLUT); %can only do one value at a time - returns RGB triplet
    for cc=1:3
        rgbImage(:,:,cc)=theVoltage(cc)+(0.*rgbImage(:,:,cc));
    end
    imText =Screen('MakeTexture', w, rgbImage);             % Make the image texture
    Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures
    vbl=Screen('Flip', w);
    Screen('Close',imText);
    newL(i) = CalLumInput('Enter luminance (cd/m2)',50);  % replace this with pause()
end
figure
plot(linearLum,newL,'o',linearLum,linearLum,'-');
Screen('CloseAll')


Screen('CloseAll');
clear mex;

ListenChar(0);
if IsWindows %might need to hide the taskbar
    ShowHideWinTaskbarMex(1)
end
