%CalibrateMonitorSpatialAngles
%plot an array of lines from a central 'fixation' point and work out maximum visual angle possible in each direction
%
%John Greenwood Nov 2016

clear all;
%% general  & input parameters

thisFile='CalibrateMonitorSpatialAngles.m';
ThisDirectory=which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));

%% setting up the screen and psychtoolbox

AssertOpenGL;
screens=Screen('Screens'); %the handle for each monitor present
Screen('Preference','SkipSyncTests',0); %Screen('Preference', 'VBLTimestampingMode', 0);
[maxStddev, minSamples, maxDeviation, maxDuration] = Screen('Preference','SyncTestSettings',0.001,[],0.15);% [, maxStddev=0.001 secs][, minSamples=50][,maxDeviation=0.1][, maxDuration=5 secs]);

if numel(screens)>1
    ExpScreen = 2;%DefInput('Which Screen? 1 or 2?',1);
else
    ExpScreen=1;
end

%now open the monitor window
[w screenRect]=Screen('OpenWindow',screens(ExpScreen), 0,[],32,2); %max(Screens)

Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('TextFont', w, 'Arial');
Screen('TextSize', w, 36);

Screen('FillRect', w, [128 128 128]);
Screen('Flip', w);

%% screen/viewing parameters

sp.ScreenResX    = screenRect(3); %screen size in pixels
sp.ScreenResY    = screenRect(4);
sp.ScreenSizeX   = 59.8; %screen size in centimetres (measured for Asus VG278)
sp.ScreenSizeY   = 33.6;
sp.PixelScale    = mean([sp.ScreenSizeX./sp.ScreenResX sp.ScreenSizeY./sp.ScreenResY]);%0.035; %size of pixels in cm (take average of X/Y dimensions to assume square pixels- check!)
sp.ViewDist      = 57; %viewing distance in cm

%where to put fixation
sp.FixPosX    = round(sp.ScreenResX/2); %middle of screen
sp.FixPosY    = round(sp.ScreenResY*0.75);

%max eccentricity visible
sp.TotalVF     = (atand(((round(sp.ScreenResX/2)/2)*(sp.PixelScale))/sp.ViewDist)).*2; %use half angle (right angled triangle)
sp.MaxEcc      = sp.TotalVF;
sp.MaxPixDist  = sqrt((sp.ScreenResX^2)+(sp.ScreenResY^2)); %max possible line length (diagonal)

%% parameters and setup

EccGap              = 5;
EccHalf             = 0:EccGap:sp.MaxEcc+(3*EccGap);
EccVals             = unique([-EccHalf EccHalf]);%-40:2.5:40; %vals to print on ruler
EccValsPix          = round(((sp.ViewDist * tand(EccHalf./2))./sp.PixelScale).*2); 
AngVals             = 0:5:355;

for ang=1:numel(AngVals)
    %work out maximum x/y positions for each angle
    
    outX=1; outY=1; subs=0;
    while (outX==1 || outY==1)
        sp.MaxX(ang) = round(sp.FixPosX + cos(((pi/180) * AngVals(ang))).*(sp.MaxPixDist-subs)); %endpoint of target positions 
        sp.MaxY(ang) = round(sp.FixPosY - sin(((pi/180) * AngVals(ang))).*(sp.MaxPixDist-subs)); %endpoint of target positions
        
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
        sp.MinX(ang) = round(sp.MaxX(ang) - cos(((pi/180) * AngVals(ang))).*(sp.MaxPixDist-subs)); %start of target positions
        sp.MinY(ang) = round(sp.MaxY(ang) + sin(((pi/180) * AngVals(ang))).*(sp.MaxPixDist-subs)); %start of target positions
        
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
        EccTempX(ecc) = round(sp.FixPosX + cos(((pi/180) * AngVals(ang))).*(EccValsPix(ecc)));
        EccTempY(ecc) = round(sp.FixPosY - sin(((pi/180) * AngVals(ang))).*(EccValsPix(ecc)));
    end
    if sp.MaxX(ang)>sp.MinX(ang) %descending X values
        if sp.MaxY(ang)>sp.MinY(ang) %descending Y
            EccTempInd    = find(EccTempX<sp.MaxX(ang) & EccTempX>sp.MinX(ang) & EccTempY<sp.MaxY(ang) & EccTempY>sp.MinY(ang));
        elseif sp.MaxY(ang)==sp.MinY(ang) %horz plane
            EccTempInd    = find(EccTempX<sp.MaxX(ang) & EccTempX>sp.MinX(ang));
        else
            
            EccTempInd    = find(EccTempX<sp.MaxX(ang) & EccTempX>sp.MinX(ang) & EccTempY>sp.MaxY(ang) & EccTempY<sp.MinY(ang));
        end
    else %ascending X values
        if sp.MaxY(ang)>sp.MinY(ang) %descending Y
            if AngVals(ang)==270 %vert plane
                EccTempInd = find(EccTempY<sp.MaxY(ang) & EccTempY>sp.MinY(ang));
            else
                EccTempInd    = find(EccTempX>sp.MaxX(ang) & EccTempX<sp.MinX(ang) & EccTempY<sp.MaxY(ang) & EccTempY>sp.MinY(ang));
            end
        elseif sp.MaxY(ang)==sp.MinY(ang) %horz plane
            EccTempInd    = find(EccTempX>sp.MaxX(ang) & EccTempX<sp.MinX(ang));
        else
            if AngVals(ang)==90 %vert plane
                EccTempInd = find(EccTempY>sp.MaxY(ang) & EccTempY<sp.MinY(ang));
            else
                EccTempInd    = find(EccTempX>sp.MaxX(ang) & EccTempX<sp.MinX(ang) & EccTempY>sp.MaxY(ang) & EccTempY<sp.MinY(ang));
            end
        end
    end
    
    EccValsX{ang} = EccTempX(EccTempInd);
    EccValsY{ang} = EccTempY(EccTempInd);
    EccValsLab{ang}  = num2cell(EccHalf(EccTempInd)');
end


TickHeight = 150;

%% draw shit

ListenChar(2);
touch = 0;
KeyInd = GetKeyboardIndices;
keyBd  = min(KeyInd); %for keypad or keyboard

%draw lines across the screen
for ang=1:numel(AngVals)
    Screen('DrawLine',w,[0 0 0],sp.MinX(ang),sp.MinY(ang),sp.MaxX(ang),sp.MaxY(ang),4);
    for ecc=1:max([numel(EccValsX{ang}) numel(EccValsY{ang})]);
        Screen('DrawText', w, num2str(EccValsLab{ang}{ecc}), EccValsX{ang}(ecc)-13*numel(num2str(EccValsLab{ang}{ecc})), EccValsY{ang}(ecc)-25, [255 255 255]);
    end
end

Screen('Flip', w);%, vbl + (waitframes - 0.5) * ifi);

KbWait;

Screen('CloseAll');
clear mex;

pause(0.5);
ListenChar(0);

