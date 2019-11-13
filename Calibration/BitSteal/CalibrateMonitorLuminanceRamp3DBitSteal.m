%CalibrateMonitorLuminanceRamp3DBitSteal
%show a luminance ramp to check for contrast resolution
%setup for a 3D Asus VG278 monitor in 3D mode using Bit Stealing
%
%John Greenwood September 2014

clear all;
%% general  & input parameters

thisFile='CalibrateMonitorLuminanceRamp3DBitSteal.m';
ThisDirectory=which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));

BitsYN          = 0;%DefInput('Using the Bits#? (0=no, 1=yes)',0); %no to Bits++ Box
sp.WhereRU      = 1; %lab PC with three Asus monitors

%% setting up the screen and psychtoolbox

AssertOpenGL;
screens=Screen('Screens'); %the handle for each monitor present
%PsychImaging('PrepareConfiguration');

RightScreen = 1;% only the right screen is set up for bit stealing at present DefInput('Which Screen? 0=Left, 1=Right',1);

switch sp.WhereRU
    case 1 %on the lab PC
        if RightScreen
            gamCal='C:\Documents\MATLAB\Calibration\MonitorData\CalDataAsusVG278right3DBitSteal.mat';
        else %LeftScreen
            gamCal='C:\Documents\MATLAB\Calibration\MonitorData\CalDataAsusVG278left3Dmode.mat';
        end
    otherwise %in the office
        gamCal='/Users/John/Documents/MATLAB/Calibration/CalData.mat'; %select Gamma calibration files
end
load(gamCal); %load gamma correction functions %im=floor(LR.LtoVfun(LR,stim)); %sample call to extract correct values

InitialiseBitSteal; %set up vLUT
mgrey  = BitStealVal(0.5,LR,vLUT); %mean grey value for bit stealing
minlum = BitStealVal(0,LR,vLUT); %min lum value
maxlum = BitStealVal(1,LR,vLUT); %max lum value

Screen('Preference', 'VBLEndlineOverride', 1125); %uses the VTotal value (from MonitorAssetManager using 1920x1080)
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

NumLumVals = 1786;%2^8; set up to be ~10.8 bits (1786; expects 8 bit) but really returns ~8.8 bits (442 levels)
LRamp = linspace(0,1,sp.ScreenResX); %xramp to cover screen
LRamp = (round(LRamp.*NumLumVals))./NumLumVals; %multiply, round up, then divide to get rounded values for each possible luminance value
%now get correct B:R:G levels
for ll=1:numel(LRamp)
    Lcor(ll,:)  = BitStealVal(LRamp(ll),LR,vLUT); %can only do one value at a time - returns RGB triplet
end

Lim = zeros(sp.ScreenResY,sp.ScreenResX,3); %preload image array
for cc=1:3 %for each colour
    Lim(:,:,cc) = repmat(Lcor(:,cc)',[sp.ScreenResY 1]); %extend image (using bit stealing values) to cover screen
    Lim(:,:,cc) = double(Lim(:,:,cc)); %correct image
end

Ltex  = Screen('MakeTexture',w,Lim);
srcRect  = [0 0 sp.ScreenResX sp.ScreenResY];
destRect = [0 0 sp.ScreenResX sp.ScreenResY];

MgreyIm = zeros(sp.ScreenResY,sp.ScreenResX)+0.5;
MgreyIm = BitStealVal(MgreyIm,LR,vLUT);
Mtex    = Screen('MakeTexture',w,MgreyIm);

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
    %Screen('DrawTexture',w,Ltex,srcRect,destRect); %draw luminance ramp
    Screen('DrawTexture',w,Mtex,srcRect,destRect); %draw mean grey
    Screen('Flip', w);%, vbl + (waitframes - 0.5) * ifi);
    
    [secs,kc] = KbWait;
end

Screen('CloseAll');
clear mex;

pause(0.5);
ListenChar(0);

