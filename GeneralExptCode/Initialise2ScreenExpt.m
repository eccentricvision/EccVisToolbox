%Initialise2ScreenExpt
%screen and graphics initialisation for psychophysical tasks with a main computer and a secondary experiment screen
%needs blackout as a variable to already be set

% Graphics initialisation
AssertOpenGL;
screens = Screen('Screens'); %if on PC, will be 0/1/2, otherwise 0/1
comp    = Screen('Computer'); %get the computer details

if IsOSX %some hacks to make psychtoolbox work even with slightly odd timestamps
    Screen('Preference','SkipSyncTests',0); %Screen('Preference', 'VBLTimestampingMode', 0);
    Screen('Preference', 'ConserveVRAM',8192);%16384);%4096); %enables kPsychUseBeampositionQueryWorkaround - hopefully fixes issue with PTB not detecting the VBL values
    [maxStddev, minSamples, maxDeviation, maxDuration] = Screen('Preference','SyncTestSettings',0.01,[],[]);% [, maxStddev=0.001 secs][, minSamples=50][,maxDeviation=0.1][, maxDuration=5 secs]);
end

if IsWin
    FileLoc = which('Initialise2ScreenExpt');
    
    username=getenv('USERNAME'); %get windows username
    if strcmp(username,'JohnG') %then you're in Moorfields - hacky way to set a different computer name
        comp.machineName = 'DakinLab01';
    elseif strcmp(username,'EyeLink User')
        comp.machineName = 'EyelinkWestonCRF'; %eyelink machine in maria's lab
    else
        comp.machineName = 'greenwood01'; %hacky way to give the computer a machine name since this is broken in Windows 7/Vista
    end
end

[sp.WhereRU,LR,gamCal,gammaMethod,ExpScreen,MainScreen,TwoKBs] = LoadGammaCal(comp,screens); %load gamma calibration file and get WhereRU value, LR and gammaMethod

if UseColour==1
    switch sp.WhereRU %1=Office, 2=Lab, 3=Laptop
        case 1 %in John's Office
            colCal='/Users/john.greenwood/Documents/MATLAB/Calibration/MonitorData/OfficeCalDataRGB.mat'; %select Gamma calibration files
        case 2 %laptop
            colCal='/Users/John/Documents/MATLAB/Calibration/MonitorData/CalDataRGB.mat';
        case 3 %in the lab
            colCal='/Users/Lab/Documents/MATLAB/Calibration/MonitorData/CalDataDiamondPlusRGB.mat'; %the Gamma calibration file in the same directory (change this if it's elsewhere)
        case 9 %new office iMac
            colCal='/Users/lab/Documents/MATLAB/Calibration/MonitorData/CalDataDisplayPlusPlusRGB.mat'; %select Gamma calibration files
    end
    load(colCal); %load gamma correction for colour -ie loads Lred Lblue Lgreen.
end

switch gammaMethod
    case 0 %no extra methods, just gamma correction
        mgrey  = round(LR.LtoVfun(LR,LR.LMax/2)); %mean grey value for bitsbox
        minlum = round(LR.LtoVfun(LR,LR.LMin)); %min lum value (keep these values as multipliers rather than RGB values for bitsbox as in mgrey)
        maxlum = round(LR.LtoVfun(LR,LR.LMax)); %max lum value
        minBits= round(LR.LtoVfun(LR,LR.LMax/2)); %min grey value for bitsbox
        maxBits= round(LR.LtoVfun(LR,LR.LMax)); %mean grey value for bitsbox
        arcBits= round(LR.LtoVfun(LR,(0.75*LR.LMax))); %brightness of trial indicator arc
    case 1 %bitsbox plus gamma correction
        mgrey  = LtoVConvert(LR,round(LR.LMax/2),1); %mean grey value for bitsbox
        minlum = round(LR.LtoVfun(LR,LR.LMin)); %min lum value (keep these values as multipliers rather than RGB values for bitsbox as in mgrey)
        maxlum = round(LR.LtoVfun(LR,LR.LMax)); %max lum value
        minBits= LtoVConvert(LR,round(LR.LMin),1); %min grey value for bitsbox
        maxBits= LtoVConvert(LR,round(LR.LMax),1); %mean grey value for bitsbox
        arcBits= LtoVConvert(LR,round(0.75*LR.LMax),1); %brightness of trial indicator arc
    case 2 %bit stealing and gamma correction
        InitialiseBitSteal %set up vLUT
        mgrey  = BitStealVal(0.5,LR,vLUT); %mean grey value for bit stealing
        minlum = BitStealVal(0,LR,vLUT); %min lum value
        maxlum = BitStealVal(1,LR,vLUT); %max lum value
end

if blackout
    [w2 screenRect2]=Screen('OpenWindow',screens(MainScreen),0,[],32,2); %get reference and resolution for main monitor
    centX2=screenRect2(3)/2; centY2=screenRect2(4)/2;
    blackim=zeros(screenRect2(3),screenRect2(4));
    sp.ScreenResX2  = screenRect2(3);
    sp.ScreenResY2  = screenRect2(4);
    if IsOSX %then likely in the office
        sp.ScreenSizeX2 = 59.9; %imac 27"
        sp.ScreenSizeY2 = 33.9;
    else %on a PC
        sp.ScreenSizeX2 = 40; %NEED TO MEASURE THIS
        sp.ScreenSizeY2 = 30;
    end
    sp.PixelScale2  = mean([sp.ScreenSizeX2./sp.ScreenResX2 sp.ScreenSizeY2./sp.ScreenResY2]);%0.035; %size of pixels in cm (take average of X/Y dimensions to assume square pixels- check!)
    Screen('BlendFunction', w2, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('FillRect',w2, [0 0 0]);
    Screen('Flip', w2);
end

%now draw to experimental monitor
[w screenRect]=Screen('OpenWindow',screens(ExpScreen), 0,[],32,2); %max(Screens)
sp.centX=screenRect(3)/2;
sp.centY=screenRect(4)/2;

%Screen parameters
sp.ScreenResX   = screenRect(3); %screen size in pixels
sp.ScreenResY   = screenRect(4);
if IsOSX %then likely using a CRT monitor - set up for the Sony Trinitron in the lab
    if sp.WhereRU==9 %display++
    sp.ScreenSizeX  = 71.0; %screen size in centimetres
    sp.ScreenSizeY  = 39.5;
    else %CRT
    sp.ScreenSizeX  = 40; %screen size in centimetres
    sp.ScreenSizeY  = 30;
    end
else %on a PC the likely screen is a Sony Trinitron
    sp.ScreenSizeX  = 48.1; %screen size in centimetres
    sp.ScreenSizeY  = 31.0;
end
sp.PixelScale   = mean([sp.ScreenSizeX./sp.ScreenResX sp.ScreenSizeY./sp.ScreenResY]);%0.035; %size of pixels in cm (take average of X/Y dimensions to assume square pixels)
sp.WhichScreen  = ExpScreen; %taken from LoadGammaCal now

if gammaMethod==1 %bits box
    bitsPlusRect = [0     0   524     1];               % The window we  write the Bits++ CLUT into
    newClutRow = BitsPlusEncodeClutRow((2^16-1).*hsv(256));  % Encode CLUT  ('hsv') using PTB routine
    clutText =Screen('MakeTexture', w, newClutRow);          % Make the  CLUT texture
    Screen('DrawTexture', w, clutText, [], bitsPlusRect,0,0);
    vbl=Screen('Flip', w);
end

%draw blank screen
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FillRect',w,mgrey);
Screen('Flip', w);

% Query duration of monitor refresh interval:
sp.ifi=Screen('GetFlipInterval', w);
vbl=Screen('Flip', w);


