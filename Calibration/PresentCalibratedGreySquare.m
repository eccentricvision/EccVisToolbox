% PresentCalibratedGreySquare
% script to present a grey square of a given contrast with properly calibrated luminance values

% J Greenwood July 2016

%% parameters

clear all;

thisFile      = 'CalibrateMonitorLuminanceRamp.m';
ThisDirectory = which(thisFile); 
ThisDirectory = ThisDirectory(1:end-length(thisFile));

BitsYN  = 0;%DefInput('Using the Bits#? (0=no, 1=yes)',0); %no to Bits++ Box

% Image dimensions
imsize = 256;
p      = 3;

BGlum = 0.5; %want a mean grey background (specified in image units: 0-1)
ImCon = 0.25; %desired Weber contrast for a simple stimulus which is ((StimLum - BGlum)/BGlum)

%% initialise psychtoolbox, load calibration file and get screen details

AssertOpenGL;
Screen('Preference','SkipSyncTests',1); %we don't need these here and it increases generalisability of the code

screens=Screen('Screens');

if ispc
    gamCal=strcat(ThisDirectory,'MonitorData\LacieDaylightCalData.mat'); %select Gamma calibration files
else %mac
    gamCal=strcat(ThisDirectory,'MonitorData/LacieDaylightCalData.mat'); %select Gamma calibration files
end
load(gamCal); %load gamma correction function & luminance values

%now we can get some parameters that we need to set the stimulus contrast/luminance
mgrey  = round(LR.LtoVfun(LR,LR.LMax/2)); %mean grey value (in voltage units 0-255)
minlum = round(LR.LtoVfun(LR,LR.LMin)); %min lum value
maxlum = round(LR.LtoVfun(LR,LR.LMax)); %max lum value

if ispc %use screen 1
    if numel(screens)>1
        screenIndex = screens(3);
    else
        screenIndex=max(screens);
    end
else %use max screens
    screenIndex=max(screens);
end

Use3Dmode = 0;
if Use3Dmode
    [w screenRect]=Screen('OpenWindow',screenIndex, 0,[],32,2,1); %stereomode =1 (shutters)
else %non 3D mode
    [w screenRect]=Screen('OpenWindow',screenIndex, 0,[],32,2);
end

Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FillRect',w, [mgrey mgrey mgrey]); % this is the calibrated mean grey
vbl=Screen('Flip', w);

if ispc %might need to hide the taskbar5
    ShowHideWinTaskbarMex(0)
end

%% correct the luminance and show our square

SquareIm     = ones(imsize,imsize); %draw a square of max brightness (easiest to start with all ones and then work out contrast next)
SquareIm     = ((SquareIm.*BGlum).*ImCon) + BGlum; %this is the luminance that gives the correct Weber contrast in the image space (0-1) - rearranged Weber contrast formula
SquareIm(SquareIm>1)=1; %always a good idea to check you're still in the 0-1 range in case your maths is shit
SquareIm(SquareIm<0)=0;

%now to get the calibrated luminance value we multiply our image by the maximum luminance to put things in the desired cd/m2 range
%and run 'LtoVConvert' to get the right voltage value using the calibration data
SquareImCORR = LtoVConvert(LR,(SquareIm.*LR.LMax),BitsYN); %wants a 2D input, returns a 3D output (for RGB layers)

imTex  = Screen('MakeTexture', w, SquareImCORR);             % Make the image texture
Screen('DrawTexture', w, imTex, [], [], 0);
%flip the screen
vbl=Screen('Flip', w);

KbWait; %wait for a keypress
pause(0.1); %wait briefly to avoid KbWait still being active (exits the loop otherwise)
Screen('Close',imTex); %close the texture

%% finish up

Screen('CloseAll');

if ispc %might need to restore the taskbar
    ShowHideWinTaskbarMex(1)
end

