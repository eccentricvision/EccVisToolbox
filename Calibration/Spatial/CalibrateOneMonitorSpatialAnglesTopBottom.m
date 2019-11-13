%CalibrateOneMonitorSpatialAnglesTopBottom
%work out arrangement of 2 monitors (with only one enabled at a time) and if screen coordinates correspond to physical coordinates
%for Asus monitors in top/bottom config
%
%John Greenwood July 2014

clear all;
%% general  & input parameters

thisFile='CalibrateOneMonitorSpatialAnglesTopBottom.m';
ThisDirectory=which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));

BitsYN          = 0;%DefInput('Using the Bits#? (0=no, 1=yes)',0); %no to Bits++ Box
sp.WhereRU      = 1; %lab PC with three Asus monitors

%% setting up the screen and psychtoolbox

AssertOpenGL;
screens=Screen('Screens'); %the handle for each monitor present
%PsychImaging('PrepareConfiguration');

LowerScreen = DefInput('Which Screen? 0=Upper, 1=Lower',0);

switch sp.WhereRU
    case 1 %on the lab PC
        if LowerScreen
            gamCal='C:\Documents\MATLAB\Calibration\CalDataAsusVG278right3Dmode.mat';
        else %LeftScreen
            gamCal='C:\Documents\MATLAB\Calibration\CalDataAsusVG278left3Dmode.mat';
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

%now open the monitor window
[w screenRect]=Screen('OpenWindow',screens, 0,[],32,2); %max(Screens)
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
sp.ViewDist      = 65; %57; %60 %70 %50; %viewing distance in cm

sp.UpperBezelSize   = 2.5; %size of monitor bezel/edge in cm (2.2cm each with LED fixation due to gap, 2cm without)
sp.UpperBezelPixels = round(sp.UpperBezelSize./sp.PixelScale); %how many pixels are hidden behind the bezel
sp.LowerBezelSize   = 2.2;
sp.LowerBezelPixels = round(sp.LowerBezelSize./sp.PixelScale); %how many pixels are hidden behind the bezel
sp.MonGapSize       = 0.5; %size of gap between monitors
sp.MonGapPixels     = round(sp.MonGapSize./sp.PixelScale); %how many pixels are hidden behind the gap

%where to find the 'zero pos' = midpoint of both screens
if LowerScreen
    sp.ZeroPosX    = round(sp.ScreenResX/2);%-round(sp.BezelPixels); %right screen
    sp.ZeroPosY    = -(sp.LowerBezelPixels+round(sp.MonGapPixels/2));%720;% 720];%[sp.ScreenResY-150 sp.ScreenResY-150];
else %UpperScreen
    sp.ZeroPosX    = round(sp.ScreenResX/2);%round(screenRect(3) + round(sp.BezelPixels)); %left screen
    sp.ZeroPosY    = sp.ScreenResY+sp.UpperBezelPixels+round(sp.MonGapPixels/2);%720;% 720];%[sp.ScreenResY-150 sp.ScreenResY-150];
end

%max eccentricity visible
sp.TotalVF      = PixToVA(sp.ViewDist,sp.PixelScale,((sp.ScreenResX*2)+sp.UpperBezelPixels+sp.LowerBezelPixels+sp.MonGapPixels)); %size of whole visual field
sp.MaxEcc       = sp.TotalVF/2;
sp.MaxPixDist   = sqrt((sp.ScreenResX^2)+(sp.ScreenResY^2)); %max possible line length (diagonal)

%% parameters and setup

EccGap              = 5;
EccHalf             = 0:EccGap:sp.MaxEcc+(3*EccGap);
EccVals             = unique([-EccHalf EccHalf]);%-40:2.5:40; %vals to print on ruler
EccValsPix          = round(VAToPix(sp.ViewDist,sp.PixelScale,EccHalf));
if LowerScreen
    AngVals         = 225:5:315;%5:5:175;%-75:5:75; % [0 25 155 180];%[-45:5:75 105:5:225]; %[-60:15:60 120:15:240];
else %UpperScreen
    AngVals         = 45:5:135;%5:5:175;%105:5:255; % [0 25 155 180];%[-45:5:75 105:5:225]; %[-60:15:60 120:15:240];
end

for ang=1:numel(AngVals)
    %work out maximum x/y positions for each angle
    
    outX=1; outY=1; subs=0;
    while (outX==1 || outY==1)
        sp.MaxX(ang) = round(sp.ZeroPosX + cos(deg2rad(AngVals(ang))).*(sp.MaxPixDist-subs)); %endpoint of target positions
        sp.MaxY(ang) = round(sp.ZeroPosY - sin(deg2rad(AngVals(ang))).*(sp.MaxPixDist-subs)); %endpoint of target positions
        
        if sp.MaxX(ang)>sp.ScreenResX
            outX=1;
        elseif sp.MaxX(ang)<0
            outX=1;
        else
            outX=0;
        end
        if sp.MaxY(ang)>sp.ScreenResY
            outY=1;
        elseif sp.MaxY(ang)<0
            outY=1;
        else
            outY=0;
        end
        subs=subs+1; %value to subtract from maxdist
    end
    
    %work out minimum x/y positions for each angle
    outX=1; outY=1; subs=0;
    while (outX==1 || outY==1)
        sp.MinX(ang) = round(sp.MaxX(ang) - cos(deg2rad(AngVals(ang))).*(sp.MaxPixDist-subs)); %start of target positions
        sp.MinY(ang) = round(sp.MaxY(ang) + sin(deg2rad(AngVals(ang))).*(sp.MaxPixDist-subs)); %start of target positions
        
        if sp.MinX(ang)>sp.ScreenResX
            outX=1;
        elseif sp.MinX(ang)<0
            outX=1;
        else
            outX=0;
        end
        if sp.MinY(ang)>sp.ScreenResY
            outY=1;
        elseif sp.MinY(ang)<0
            outY=1;
        else
            outY=0;
        end
        
        subs=subs+1;
    end
    
    % plot([sp.MinX(ang) sp.MaxX(ang)],[sp.MinY(ang) sp.MaxY(ang)],'ro-'); hold on;
    % plot([sp.MinX(ang)],[sp.MinY(ang)],'bo'); hold on;
    
    for ecc=1:numel(EccHalf)
        EccTempX(ecc) = round(sp.ZeroPosX + cos(deg2rad(AngVals(ang))).*(EccValsPix(ecc)));
        EccTempY(ecc) = round(sp.ZeroPosY - sin(deg2rad(AngVals(ang))).*(EccValsPix(ecc))); %NB inverted Y values
    end
    
    if sp.MaxY(ang)>sp.MinY(ang) %descending Y - upper monitor (inverted Y)
        if sp.MaxX(ang)>sp.MinX(ang) %descending X values
            EccTempInd    = find(EccTempX<sp.MaxX(ang) & EccTempX>sp.MinX(ang) & EccTempY<sp.MaxY(ang) & EccTempY>sp.MinY(ang));
        elseif sp.MaxX(ang)==sp.MinX(ang) %vert plane
            EccTempInd    = find(EccTempY<sp.MaxY(ang) & EccTempY>sp.MinY(ang));
        else %ascending Y
            EccTempInd    = find(EccTempX>sp.MaxX(ang) & EccTempX<sp.MinX(ang) & EccTempY<sp.MaxY(ang) & EccTempY>sp.MinY(ang));
        end
    elseif sp.MaxY(ang)==sp.MinY(ang) %horz plane - ignore y dimension (unchanging)
        EccTempInd    = find(EccTempX>sp.MaxX(ang) & EccTempX<sp.MinX(ang));
    else %ascending Y - lower monitor (due to inverted Y)
        if sp.MaxX(ang)>sp.MinX(ang) %descending X
            EccTempInd    = find(EccTempX<sp.MaxX(ang) & EccTempX>sp.MinX(ang) & EccTempY>sp.MaxY(ang) & EccTempY<sp.MinY(ang));
        elseif sp.MaxX(ang)==sp.MinX(ang) %vert plane - ignore x dimension (unchanging)
            EccTempInd    = find(EccTempY>sp.MaxY(ang) & EccTempY<sp.MinY(ang));
        else %ascending X
            EccTempInd    = find(EccTempX>sp.MaxX(ang) & EccTempX<sp.MinX(ang) & EccTempY>sp.MaxY(ang) & EccTempY<sp.MinY(ang));
        end
    end
    
    %
    %         if sp.MaxX(ang)>sp.MinX(ang) %descending X values
    %             EccTempInd    = find(EccTempX<sp.MaxX(ang) & EccTempX>sp.MinX(ang) & EccTempY>sp.MaxY(ang) & EccTempY<sp.MinY(ang));
    %         elseif sp.MaxX(ang)==sp.MinX(ang) %vert plane
    %             EccTempInd    = find(EccTempY>sp.MaxY(ang) & EccTempY<sp.MinY(ang));
    %         else%ascending X
    %             EccTempInd    = find(EccTempX>sp.MaxX(ang) & EccTempX<sp.MinX(ang) & EccTempY>sp.MaxY(ang) & EccTempY<sp.MinY(ang));
    %         end
    %
    %         EccTempInd    = find(EccTempX>sp.MaxX(ang) & EccTempX<sp.MinX(ang));
    %
    %
    %     end
    %
    EccValsX{ang} = EccTempX(EccTempInd);
    EccValsY{ang} = EccTempY(EccTempInd);
    EccValsLab{ang}  = num2cell(EccHalf(EccTempInd)');
end

TickHeight = 150;

%% draw shit

ListenChar(2);
touch = 0;
KeyInd = GetKeyboardIndices;
keyBd  = max(KeyInd);%min(KeyInd);%min(KeyInd);% %for keypad or keyboard

%Screen('DrawLine', windowPtr [,color], fromH, fromV, toH, toV [,penWidth]);

%draw lines across the (visible) screens
for ang=1:numel(AngVals)
    Screen('DrawLine',w,[0 0 0],sp.MinX(ang),sp.MinY(ang),sp.MaxX(ang),sp.MaxY(ang),4);
    for ecc=1:numel(EccValsX{ang})
        Screen('DrawText', w, num2str(EccValsLab{ang}{ecc}), EccValsX{ang}(ecc)-13*numel(num2str(EccValsLab{ang}{ecc})), EccValsY{ang}(ecc)-25, [255 255 255]);
    end
end

%  %left screen
% Screen('DrawLine',w(2),[0 0 0],0,centY(2),screenRect(2,3),centY(2),4); %right screen
%
% %now draw the ticks along the horz line
% for ecc = 1:numel(EccVals)
%     Screen('DrawLine', w(WS(ecc)),[0 0 0],EccLocX(ecc),centY(WS(ecc))-round(0.5*TickHeight),EccLocX(ecc),centY(WS(ecc))+round(0.5*TickHeight),4);
%
% end
%
if LowerScreen
    Screen('DrawText', w, 'Calibration - lower screen',1350, 220, 1);
else
    Screen('DrawText', w, 'Calibration - upper screen',1350,  220, 1);
end

Screen('Flip', w);%, vbl + (waitframes - 0.5) * ifi);

KbWait;

Screen('CloseAll');
clear mex;

pause(0.5);
ListenChar(0);

