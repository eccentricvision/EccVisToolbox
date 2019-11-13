%CalibrateMonitorLuminanceRamp
%show a luminance ramp to check for contrast resolution
%setup for a 3D Asus VG278 monitor
%
%John Greenwood September 2014

%% general  & input parameters

clear all;

thisFile='CalibrateMonitorLuminanceRamp.m';
ThisDirectory=which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));

BitsYN          = 0;%DefInput('Using the Bits#? (0=no, 1=yes)',0); %no to Bits++ Box

%% setting up the screen and psychtoolbox

AssertOpenGL;
Screen('Preference','SkipSyncTests',1); %we don't need these here and it increases generalisability of the code
screens=Screen('Screens'); %the handle for each monitor present
if IsOSX %some hacks to make psychtoolbox work even with slightly odd timestamps
    Screen('Preference','SkipSyncTests',0); %Screen('Preference', 'VBLTimestampingMode', 0);
    Screen('Preference', 'ConserveVRAM',8192);%16384);%4096); %enables kPsychUseBeampositionQueryWorkaround - hopefully fixes issue with PTB not detecting the VBL values
    [maxStddev, minSamples, maxDeviation, maxDuration] = Screen('Preference','SyncTestSettings',0.01,[],[]);% [, maxStddev=0.001 secs][, minSamples=50][,maxDeviation=0.1][, maxDuration=5 secs]);
end
%PsychImaging('PrepareConfiguration');

if ispc
    gamCal=strcat(ThisDirectory,'MonitorData\LacieDaylightCalData.mat'); %select Gamma calibration files
else %mac
    gamCal=strcat(ThisDirectory,'MonitorData/CalDataAsusVG278_MEHno3D.mat'); %select Gamma calibration files
end
load(gamCal); %load gamma correction functions %im=floor(LR.LtoVfun(LR,stim)); %sample call to extract correct values

mgrey  = round(LR.LtoVfun(LR,LR.LMax/2)); %mean grey value
minlum = round(LR.LtoVfun(LR,LR.LMin)); %min lum value (keep these values as multipliers rather than RGB values for bitsbox as in mgrey)
maxlum = round(LR.LtoVfun(LR,LR.LMax)); %max lum value

Screen('Preference','SkipSyncTests',0); %Screen('Preference', 'VBLTimestampingMode', 0);

if IsWindows %use screen 1
    if numel(screens)>1
        screenIndex = screens(3);
    else
        screenIndex=max(screens);
    end
else %use max screens
    screenIndex=max(screens);
end

%now open the monitor window
[w screenRect]=Screen('OpenWindow',screenIndex, 0,[],32,2);
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
sp.ScreenSizeX   = 40;%59.8; %screen size in centimetres (measured for Asus VG278)
sp.ScreenSizeY   = 30;%33.6;
sp.PixelScale    = mean([sp.ScreenSizeX./sp.ScreenResX sp.ScreenSizeY./sp.ScreenResY]);%0.035; %size of pixels in cm (take average of X/Y dimensions to assume square pixels- check!)
sp.ViewDist      = 60;%65;%57; %60 %70 %50; %viewing distance in cm

%% parameters and setup

NumLumVals = 7;
LRamp      = linspace(0,1,NumLumVals); %luminance values to present
LRamp      = (repmat(LRamp,[1 ceil(sp.ScreenResX/NumLumVals) 1]));
LRamp      = sort(LRamp(:,1:sp.ScreenResX)); %make sure have the right number of values
Lim        = repmat(LRamp,[sp.ScreenResY/2 1]); %extend image

LimUnCorr = repmat(Lim*255,[1 1 3]); %uncorrected ramp
LimCorr   = LtoVConvert(LR,round(Lim*LR.LMax),BitsYN); %corrected ramp

Ltex  = Screen('MakeTexture',w,LimUnCorr);
Ltex2 = Screen('MakeTexture',w,LimCorr);
srcRect   = [0 0 sp.ScreenResX sp.ScreenResY/2];
destRect  = [0 0 sp.ScreenResX sp.ScreenResY/2];
destRect2 = [0 (sp.ScreenResY/2) sp.ScreenResX sp.ScreenResY];

%% draw shit

ListenChar(2);
touch = 0;
KeyInd = GetKeyboardIndices;
keyBd  = min(KeyInd);%min(KeyInd);%min(KeyInd);% %for keypad or keyboard

Screen('DrawTexture',w,Ltex,srcRect,destRect); %draw luminance ramp - corrected
Screen('DrawTexture',w,Ltex2,srcRect,destRect2); %uncorrected
Screen('Flip', w);%, vbl + (waitframes - 0.5) * ifi);

KbWait;

Screen('CloseAll');
clear mex;

pause(0.5);
ListenChar(0);

