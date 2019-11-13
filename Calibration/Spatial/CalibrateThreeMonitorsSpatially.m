%CalibrateThreeMonitorsSpatially
%work out arrangement of three monitors and if screen coordinates correspond to physical coordinates
%
%John Greenwood March 2014

clear all;
%% general  & input parameters

thisFile='CalibrateThreeMonitorsSpatially.m';
ThisDirectory=which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));

BitsYN          = 0;%DefInput('Using the Bits#? (0=no, 1=yes)',0); %no to Bits++ Box
sp.WhereRU      = 1; %lab PC with three Asus monitors

%% setting up the screen and psychtoolbox

AssertOpenGL;
screens=Screen('Screens'); %the handle for each monitor present
%PsychImaging('PrepareConfiguration');

NewScreen(1) = screens(4); %4 %middle screen
NewScreen(2) = screens(2); %2%left screen
NewScreen(3) = screens(3); %3%right screen

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

%now open the monitor windows - NB screens(1) = 0 which is the full wrapped desktop
for mon=1:3
    [w(mon) screenRect(mon,:)]=Screen('OpenWindow',NewScreen(mon), 0,[],32,2); %max(Screens)
    %get monitor parameters
    centX(mon)=screenRect(mon,3)/2;
    centY(mon)=screenRect(mon,4)/2; %find the x/y centre of the screen
end

for mon=1:3
    Screen('BlendFunction', w(mon), GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('TextFont', w(mon), 'Arial');
    Screen('TextSize', w(mon), 36);
    
    Screen('FillRect', w(mon), mgrey);
    Screen('Flip', w(mon));
end

%% screen/viewing parameters

sp.ScreenResX    = screenRect(1,3); %screen size in pixels
sp.ScreenResY    = screenRect(1,4);
sp.ScreenSizeX   = 59.8; %screen size in centimetres (measured for Asus VG278)
sp.ScreenSizeY   = 33.6;
sp.PixelScale    = mean([sp.ScreenSizeX./sp.ScreenResX sp.ScreenSizeY./sp.ScreenResY]);%0.035; %size of pixels in cm (take average of X/Y dimensions to assume square pixels- check!)
sp.ViewDist      = 100; %viewing distance in cm

sp.MidScreenVisX = 28; %how much of the middle screen is visible in cm
sp.MidPixels     = round(sp.MidScreenVisX./sp.PixelScale); %how many pixels seen on the middle screen
sp.HalfMid       = round(sp.MidPixels/2);
sp.MidHide       = round((sp.ScreenResX./2)-sp.HalfMid); %how many pixels are hidden in the flank of the middle screen
sp.BezelSize     = 2; %size of monitor bezel/edge in cm
sp.BezelPixels   = round(sp.BezelSize./sp.PixelScale); %how many pixels are hidden behind the bezel

%where to find the 'zero pos' = midpoint of all screens
sp.ZeroPosX(1)    = centX(1); %main screen
sp.ZeroPosX(2)    = round(screenRect(2,3) + (sp.MidPixels/2)) + sp.BezelPixels; %left screen
sp.ZeroPosX(3)    = -round(sp.MidPixels/2) - sp.BezelPixels;%right screen
sp.ZeroPosY       = [0 0 0];

%max eccentricity visible
sp.TotalVF      = PixToVA(sp.ViewDist,sp.PixelScale,(sp.ScreenResX*3)-(sp.MidHide*2)+(sp.BezelPixels*2)); %size of whole visual field
sp.MaxEcc       = sp.TotalVF/2;


%% parameters and setup

EccGap              = 3;
EccHalf             = 0:EccGap:sp.MaxEcc+EccGap;
EccVals             = unique([-EccHalf EccHalf]);%-40:2.5:40; %vals to print on ruler
EccValsPix          = round(VAToPix(sp.ViewDist,sp.PixelScale,EccVals));
EccValsLab          = num2cell(EccVals');

for ecc = 1:numel(EccVals) %work out which screen each tick is on
    if EccValsPix(ecc)<-sp.HalfMid
        WS(ecc) = 2; %whichscreen for each tick
    elseif EccValsPix(ecc)>sp.HalfMid
        WS(ecc) = 3;
    else %middle screen
        WS(ecc) = 1;
    end
    EccLocX(ecc) = EccValsPix(ecc) + sp.ZeroPosX(WS(ecc)); %adjust to screen coordinates
end
TickHeight = 150;

%% draw shit

%Screen('DrawLine', windowPtr [,color], fromH, fromV, toH, toV [,penWidth]);

%draw horizontal line across the (visible) screens
Screen('DrawLine',w(1),[0 0 0],centX(1)-round(0.5*sp.MidPixels),centY(1),centX(1)+round(0.5*sp.MidPixels),centY(1),4); %middle screen
Screen('DrawLine',w(2),[0 0 0],0,centY(2),screenRect(2,3),centY(2),4); %left screen
Screen('DrawLine',w(3),[0 0 0],0,centY(3),screenRect(3,3),centY(3),4); %right screen

%draw vertical lines on middle screen to show links
Screen('DrawLine',w(1),[0 0 0],centX(1)-round(0.5*sp.MidPixels),0,centX(1)-round(0.5*sp.MidPixels),screenRect(1,4),8); %middle screen vert line 1
Screen('DrawLine',w(1),[0 0 0],centX(1)+round(0.5*sp.MidPixels),0,centX(1)+round(0.5*sp.MidPixels),screenRect(1,4),8); %middle screen vert line 2

%now draw the ticks along the horz line
for ecc = 1:numel(EccVals)
    Screen('DrawLine', w(WS(ecc)),[0 0 0],EccLocX(ecc),centY(WS(ecc))-round(0.5*TickHeight),EccLocX(ecc),centY(WS(ecc))+round(0.5*TickHeight),4);
    Screen('DrawText', w(WS(ecc)), num2str(EccValsLab{ecc}), EccLocX(ecc)-13*numel(num2str(EccValsLab{ecc})), centY(WS(ecc))+TickHeight, 0);
end

Screen('DrawText', w(1), 'Calibration - middle screen',centX(1)-300, 60,0);
Screen('DrawText', w(2), 'Calibration - left screen', 20,  60, 0);
Screen('DrawText', w(3), 'Calibration - right screen',1350, 60, 0);

for mon=1:3
    Screen('Flip', w(mon));%, vbl + (waitframes - 0.5) * ifi);
end

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

