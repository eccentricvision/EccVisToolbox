%CalibrateThreeMonitorsSurround
%similar to CalibrateThreeMonitorsSpatially.m
%but three monitors are set in 'nVidia surround mode'
%and psychtoolbox only sees one monitor as a result
%work out arrangement of three monitors and if screen coordinates correspond to physical coordinates
%
%John Greenwood May 2014

clear all;
%% general  & input parameters

thisFile='CalibrateThreeMonitorsSurround.m';
ThisDirectory=which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));

BitsYN          = 0;%DefInput('Using the Bits#? (0=no, 1=yes)',0); %no to Bits++ Box
sp.WhereRU      = 1; %lab PC with three Asus monitors

%% setting up the screen and psychtoolbox

AssertOpenGL;
screens=Screen('Screens'); %the handle for each monitor present
%PsychImaging('PrepareConfiguration');

% NewScreen(1) = screens(4); %middle screen
% NewScreen(2) = screens(3); %left screen
% NewScreen(3) = screens(2); %right screen

switch sp.WhereRU
    case 1 %on the lab PC
        gamCal='C:\Documents\MATLAB\Calibration\CalDataAsus3D.mat';
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

%now open the monitor window - NB screens(1) = 0 which is the full wrapped desktop
[w,screenRect]=Screen('OpenWindow',screens(1), 0,[],32,2); %max(Screens)

%get monitor parameters
sp.centX=screenRect(3)/2;
sp.centY=screenRect(4)/2; %find the x/y centre of the screen(s)

Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('TextFont', w, 'Arial');
Screen('TextSize', w, 36);

Screen('FillRect', w, mgrey);
Screen('Flip', w);

%% screen/viewing parameters

sp.TotalScreenResX    = screenRect(3); %total screen size in pixels
sp.TotalScreenResY    = screenRect(4);
sp.IndivScreenResX    = sp.TotalScreenResX./3; %since 3 monitors are used as one big wrapper
sp.IndivScreenResY    = sp.TotalScreenResY; %same for 3 side-by-side
sp.IndivScreenSizeX   = 59.8; %screen size in centimetres (measured for Asus VG278)
sp.IndivScreenSizeY   = 33.6;

sp.PixelScale    = mean([sp.IndivScreenSizeX./sp.IndivScreenResX sp.IndivScreenSizeY./sp.IndivScreenResY]);%0.035; %size of pixels in cm (take average of X/Y dimensions to assume square pixels- check!)
sp.ViewDist      = 100; %viewing distance in cm

sp.MidScreenVisX = 28; %how much of the middle screen is visible in cm
sp.MidPixels     = round(sp.MidScreenVisX./sp.PixelScale); %how many pixels seen on the middle screen
sp.HalfMid       = round(sp.MidPixels/2);
sp.MidHide       = round((sp.IndivScreenResX./2)-sp.HalfMid); %how many pixels are hidden in the flank of the middle screen
sp.BezelSize     = 2; %size of monitor bezel/edge in cm
sp.BezelPixels   = round(sp.BezelSize./sp.PixelScale); %how many pixels are hidden behind the bezel
sp.MidShift      = sp.MidHide-sp.BezelPixels; %how far to shift

%how far to shift ticks when positioned on a given screen
sp.PosShiftX     = [-sp.MidShift 0 sp.MidShift];
sp.BezelSites    = [sp.centX-sp.HalfMid-sp.BezelPixels sp.centX-sp.HalfMid sp.centX+sp.HalfMid sp.centX+sp.HalfMid+sp.BezelPixels];
sp.ForbiddenPix  = [sp.BezelSites(1):1:sp.BezelSites(2) sp.BezelSites(3):sp.BezelSites(4)]; %invisible pixels behind the bezel

%max eccentricity visible
sp.TotalVF      = 86.92;%PixToVA(sp.ViewDist,sp.PixelScale,(sp.TotalScreenResX-(sp.MidHide*2))+(sp.BezelPixels*2)); %size of whole visual field
sp.MaxEcc       = sp.TotalVF/2;

%% parameters and setup

EccGap              = 3;
EccHalf             = 0:EccGap:sp.MaxEcc+EccGap;
EccVals             = unique([-EccHalf EccHalf]);%-40:2.5:40; %vals to print on ruler
EccValsPix          = round(VAToPix(sp.ViewDist,sp.PixelScale,EccVals));
[EccValsPix,EccInt] = setdiff(EccValsPix,sp.ForbiddenPix-sp.centX); %make sure none of the eccvals are in the forbidden zone
EccVals             = EccVals(EccInt); 
EccValsLab          = num2cell(EccVals');
for ecc = 1:numel(EccVals) %work out which screen each tick is on
    if EccValsPix(ecc)<-sp.HalfMid
        WS(ecc) = 1; %whichscreen for each tick
    elseif EccValsPix(ecc)>sp.HalfMid
        WS(ecc) = 3;
    else %middle screen
        WS(ecc) = 2;
    end
    EccLocX(ecc) = EccValsPix(ecc) + sp.centX + sp.PosShiftX(WS(ecc)); %adjust to screen coordinates
end
TickHeight = 150;

%% draw shit

HideCursor;

%Screen('DrawLine', windowPtr [,color], fromH, fromV, toH, toV [,penWidth]);

%draw horizontal line across the (visible) screens
Screen('DrawLine',w,[0 0 0],0,sp.centY,screenRect(3),sp.centY,4); %middle screen

%draw vertical lines on middle screen to show links
Screen('DrawLine',w,[0 0 0],sp.centX-round(0.5*sp.MidPixels),0,sp.centX-round(0.5*sp.MidPixels),screenRect(4),8); %middle screen vert line 1
Screen('DrawLine',w,[0 0 0],sp.centX+round(0.5*sp.MidPixels),0,sp.centX+round(0.5*sp.MidPixels),screenRect(4),8); %middle screen vert line 2

%now draw the ticks along the horz line
for ecc = 1:numel(EccVals)
    Screen('DrawLine', w,[0 0 0],EccLocX(ecc),sp.centY-round(0.5*TickHeight),EccLocX(ecc),sp.centY+round(0.5*TickHeight),4);
    Screen('DrawText', w, num2str(EccValsLab{ecc}), EccLocX(ecc)-13*numel(num2str(EccValsLab{ecc})), sp.centY+TickHeight, 0);
end

Screen('DrawText', w, 'Calibration - middle screen',sp.centX-300, 60,0);
Screen('DrawText', w, 'Calibration - left screen', sp.centX-sp.IndivScreenResX-300,  60, 0);
Screen('DrawText', w, 'Calibration - right screen',sp.centX+sp.IndivScreenResX-300, 60, 0);

Screen('Flip', w);%, vbl + (waitframes - 0.5) * ifi);

ListenChar(2);
touch = 0;
KeyInd = GetKeyboardIndices;
keyBd  = max(KeyInd);%min(KeyInd);%min(KeyInd);% %for keypad or keyboard

while ~touch%wait til keypress to clear screen
    [touch, secs, keyCode] = PsychHID('KbCheck',keyBd);
end

Screen('CloseAll');
clear mex;

pause(0.5);
ListenChar(0);

