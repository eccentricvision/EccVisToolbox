%CalibrateMonitorLuminanceRamp
%show a luminance ramp to check for contrast resolution
%setup for a 3D Asus VG278 monitor in 3D mode
%
%John Greenwood September 2014

clear all;
%% general  & input parameters

thisFile='CalibrateMonitorLuminanceRamp.m';
ThisDirectory=which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));

BitsYN          = 0;%DefInput('Using the Bits#? (0=no, 1=yes)',0); %no to Bits++ Box
sp.WhereRU      = 1; %lab PC with three Asus monitors

%% setting up the screen and psychtoolbox

AssertOpenGL;
screens=Screen('Screens'); %the handle for each monitor present
%PsychImaging('PrepareConfiguration');

RightScreen = DefInput('Which Screen? 0=Left, 1=Right',1);

switch sp.WhereRU
    case 1 %on the lab PC
        if RightScreen
            gamCal='C:\Documents\MATLAB\Calibration\MonitorData\CalDataAsusVG278right3Dmode.mat';
        else %LeftScreen
            gamCal='C:\Documents\MATLAB\Calibration\MonitorData\CalDataAsusVG278left3Dmode.mat';
        end
    case 2 %on the lab iMac (NEC DiamondView monitor)
        gamCal='/Users/jgreenwood/MatlabFiles/Calibration/CalData.mat'; %select Gamma calibration files
    case 3 %in the office
        gamCal='/Users/John/Documents/MATLAB/Calibration/CalData.mat'; %select Gamma calibration files
    case 4 %laptop
        gamCal='/Users/John/MatlabFiles/Calibration/CalData.mat'; %select Gamma calibration files
        %sp.responseKeys = {'1!' '3#'}; %CCW/CW
end
load(gamCal); %load gamma correction functions %im=floor(LR.LtoVfun(LR,stim)); %sample call to extract correct values

mgrey  = round(LR.LtoVfun(LR,LR.LMax/2)); %mean grey value
minlum = round(LR.LtoVfun(LR,LR.LMin)); %min lum value (keep these values as multipliers rather than RGB values for bitsbox as in mgrey)
maxlum = round(LR.LtoVfun(LR,LR.LMax)); %max lum value
fixlum = round(LR.LtoVfun(LR,(0.75*LR.LMax))); %brightness of trial indicator arc

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

Screen('FillRect', w, mgrey);
Screen('Flip', w);

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

%% parameters and setup

NumLumVals = 2^8;
LRamp = linspace(0,1,sp.ScreenResX); %xramp to cover screen
LRamp = (round(LRamp.*NumLumVals))./NumLumVals; %multiply, round up, then divide to get rounded values for each possible luminance value
Lim   = repmat(LRamp,[sp.ScreenResY 1]); %extend image
Lim   = LtoVConvert(LR,Lim*LR.LMax,0);%repmat(Lim*255,[1 1 3]);
Ltex  = Screen('MakeTexture',w,Lim);

Mim   = LtoVConvert(LR,(zeros(sp.ScreenResY,sp.ScreenResX)+0.5)*LR.LMax,0);
Mtex  = Screen('MakeTexture',w,Mim);

srcRect  = [0 0 sp.ScreenResX sp.ScreenResY];
destRect = [0 0 sp.ScreenResX sp.ScreenResY];

%% draw shit

ListenChar(2);
touch = 0;
KeyInd = GetKeyboardIndices;
keyBd  = max(KeyInd);%min(KeyInd);%min(KeyInd);% %for keypad or keyboard

secs = []; kc = [];
while ~any(kc)
    Screen('SelectStereoDrawBuffer', w, 0);%LE
    Screen('DrawTexture',w,Ltex,srcRect,destRect); %draw luminance ramp
    Screen('SelectStereoDrawBuffer', w, 1);%RE
%    Screen('DrawTexture',w,Ltex,srcRect,destRect); %draw luminance ramp
    Screen('DrawTexture',w,Mtex,srcRect,destRect); %draw mean luminance
    Screen('Flip', w);%, vbl + (waitframes - 0.5) * ifi);
    
    [secs,kc] = KbWait;
end

Screen('CloseAll');
clear mex;

pause(0.5);
ListenChar(0);

