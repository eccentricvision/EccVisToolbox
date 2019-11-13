%CalibrateTwoMonitorsSpatially
%work out arrangement of 2 monitors and if screen coordinates correspond to physical coordinates
%
%John Greenwood May 2014

clear all;
%% general  & input parameters

thisFile='CalibrateTwoMonitorsSpatially.m';
ThisDirectory=which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));

BitsYN          = 0;%DefInput('Using the Bits#? (0=no, 1=yes)',0); %no to Bits++ Box
sp.WhereRU      = 1; %lab PC with three Asus monitors

%% setting up the screen and psychtoolbox

AssertOpenGL;
screens=Screen('Screens'); %the handle for each monitor present
%PsychImaging('PrepareConfiguration');

NewScreen(1) = screens(3); %4 %left screen
NewScreen(2) = screens(2); %2%right screen

switch sp.WhereRU
    case 1 %on the lab PC
        gamCal='C:\Documents\MATLAB\Calibration\CalDataAsusVG278.mat';
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
for mon=1:2
    [w(mon) screenRect(mon,:)]=Screen('OpenWindow',NewScreen(mon), 0,[],32,2); %max(Screens)
    %get monitor parameters
    centX(mon)=screenRect(mon,3)/2;
    centY(mon)=screenRect(mon,4)/2; %find the x/y centre of the screen
end

for mon=1:2
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
sp.ViewDist      = 50; %viewing distance in cm

sp.BezelSize     = 2.1*2; %size of monitor bezel/edge in cm (2.1cm each with LED fixation due to gap, 2cm without)
sp.BezelPixels   = round(sp.BezelSize./sp.PixelScale); %how many pixels are hidden behind the bezel

%where to find the 'zero pos' = midpoint of both screens
sp.ZeroPosX(1)    = round(screenRect(2,3) + round(sp.BezelPixels/2)); %left screen
sp.ZeroPosX(2)    = -round(sp.BezelPixels/2); %right screen
sp.ZeroPosY       = [0 0];

%max eccentricity visible
sp.TotalVF      = PixToVA(sp.ViewDist,sp.PixelScale,(sp.ScreenResX*2)+(sp.BezelPixels)); %size of whole visual field
sp.MaxEcc       = sp.TotalVF/2;

%% parameters and setup

EccGap              = 5;
EccHalf             = 0:EccGap:sp.MaxEcc+(3*EccGap);
EccVals             = unique([-EccHalf EccHalf]);%-40:2.5:40; %vals to print on ruler
EccValsPix          = round(VAToPix(sp.ViewDist,sp.PixelScale,EccVals));
 
EccValsInd  = find(abs(EccValsPix)>round(sp.BezelPixels/2)); %take out hidden eccentricities
EccVals     = EccVals(EccValsInd);
EccValsPix  = EccValsPix(EccValsInd);
EccValsLab  = num2cell(EccVals');

for ecc = 1:numel(EccVals) %work out which screen each tick is on
    if EccValsPix(ecc)<0
        WS(ecc) = 1; %whichscreen for each tick
    elseif EccValsPix(ecc)>0
        WS(ecc) = 2;
    end
    EccLocX(ecc) = EccValsPix(ecc) + sp.ZeroPosX(WS(ecc)); %adjust to screen coordinates
end
TickHeight = 150;

%% draw shit

ListenChar(2);
touch = 0;
KeyInd = GetKeyboardIndices;
keyBd  = max(KeyInd);%min(KeyInd);%min(KeyInd);% %for keypad or keyboard

%Screen('DrawLine', windowPtr [,color], fromH, fromV, toH, toV [,penWidth]);

%draw horizontal line across the (visible) screens
Screen('DrawLine',w(1),[0 0 0],0,centY(1),screenRect(1,3),centY(1),4); %left screen
Screen('DrawLine',w(2),[0 0 0],0,centY(2),screenRect(2,3),centY(2),4); %right screen

%now draw the ticks along the horz line
for ecc = 1:numel(EccVals)
    Screen('DrawLine', w(WS(ecc)),[0 0 0],EccLocX(ecc),centY(WS(ecc))-round(0.5*TickHeight),EccLocX(ecc),centY(WS(ecc))+round(0.5*TickHeight),4);
    Screen('DrawText', w(WS(ecc)), num2str(EccValsLab{ecc}), EccLocX(ecc)-13*numel(num2str(EccValsLab{ecc})), centY(WS(ecc))+TickHeight, 0);
end

Screen('DrawText', w(1), 'Calibration - left screen', 20,  60, 0);
Screen('DrawText', w(2), 'Calibration - right screen',1350, 60, 0);

%for mon=1:3
    Screen('Flip', w(mon),[],[],[],1);%, vbl + (waitframes - 0.5) * ifi);
%end

KbWait;
% while ~touch%wait til keypress to clear screen
%     [touch, secs, keyCode] = PsychHID('KbCheck',keyBd);
% end

Screen('CloseAll');
clear mex;

pause(0.5);
ListenChar(0);

