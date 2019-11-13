% CalibrateDKLcolours
% function to measure the luminance/chromaticity values of a range of colours in DKL space with a CRT
% uses a fixed luminance and fixed colour contrast, then swings through the hue angles
% J Greenwood April 2015

clear all;

thisFile='CalibrateDKLcolours.m';
ThisDirectory=which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));

%load calibrated colour values
WhichMonFile = strcat(ThisDirectory,'MonitorData/CalDataDiamondPlusRGB.mat');
load(WhichMonFile);%load('/Users/John/Documents/MATLAB/Calibration/MonitorData/OfficeCalDataRGB.mat');

%work out DKL values for a ring of hues and convert to RGB vals
LV          = DefInput('Luminance Value? -1 to 1',0.2);%LV          = 0.2; %keep values along middle isoluminant plane
ContrastVal = DefInput('Colour Contrast? 0-1',0.2); %ContrastVal = 0.2;
HueAngles   = -deg2rad(0:15:345);%(240:1:300);

for hue = 1:numel(HueAngles)
    [LMval(hue),Sval(hue)] = pol2cart(HueAngles(hue),ContrastVal);
    
    imval = DKL2RGB([LV LMval(hue) Sval(hue)],Lred,Lgreen,Lblue);
    imval = round(imval.*255)./255; %quantise values to 8-bit range
    
    for cc=1:3
        DKL.IsReal(hue,cc) = isreal(imval(cc)); %store whether imaginary numbers come out or not
    end
    imval = real(imval);
    imval(imval>1)=1;
    imval(imval<0)=0;
    
    DKL.RGBval(hue,:) = imval*255;
end

BlackBG=1;
if BlackBG
    BGcol = [0 0 0];
else %grey BG
    BGcol = [128 128 128];
end

AssertOpenGL;
screens=Screen('Screens');

if IsWindows %use screen 1
    screenNumber=screens(2);%1;%max(screens);
else %use max screens
    screenNumber=max(screens);
end
[w screenRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);

Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FillRect',w, BGcol);%[128 128 128]); % this is grey - in Mono++ the blue carries the LUT index
vbl=Screen('Flip', w);

if IsWindows %might need to hide the taskbar
    ShowHideWinTaskbarMex(0)
end

m=256; n=256; p=3;                                  % Image dimensions
rgbImage=zeros(m,n,p);                              % This will be our RGB stimulus

for hue=1:numel(HueAngles)
    rgbImage(:,:,1)=zeros(m,n) + DKL.RGBval(hue,1);
    rgbImage(:,:,2)=zeros(m,n) + DKL.RGBval(hue,2);
    rgbImage(:,:,3)=zeros(m,n) + DKL.RGBval(hue,3);
    
    imText =Screen('MakeTexture', w, rgbImage);             % Make the image texture
    Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures
    vbl=Screen('Flip', w);
    DKL.LumVals(hue)  = DefInput('Enter luminance (cd/m2)',50);  % replace this with pause()
    DKL.cXvals(hue)   = DefInput('Enter chroma Xval',0.5);
    DKL.cYvals(hue)   = DefInput('Enter chroma Yval',0.5);
    Screen('Close',imText);
    
    Screen('FillRect',w, BGcol);%[128 128 128]); % this is grey - in Mono++ the blue carries the LUT index
    vbl=Screen('Flip', w);
    pause(0.1); %just a little blip to show the colour has changed
end

Screen('CloseAll')

if IsWindows %might need to restore the taskbar
    ShowHideWinTaskbarMex(1)
end

DKL.cZvals = 1 - DKL.cXvals - DKL.cYvals; % z = 1 - x - y;

figure
subplot(1,3,1); %plot luminance values
plot(rad2deg(-HueAngles),DKL.LumVals,'k-'); %draw the line
hold on;
for hue=1:numel(HueAngles) %draw individual points
plot(rad2deg(-HueAngles(hue)),DKL.LumVals(hue),'o-','Color',DKL.RGBval(hue,:)./255,'MarkerFaceColor',DKL.RGBval(hue,:)./255);
end
title('Luminance values');
xlabel('Hue Angle (deg)')
ylabel('Luminance (cd/m2)');
axis square

subplot(1,3,2);
plot(DKL.cXvals,DKL.cYvals,'k-'); %draw the line
hold on;
for hue=1:numel(HueAngles)
plot(DKL.cXvals(hue),DKL.cYvals(hue),'o-','Color',DKL.RGBval(hue,:)./255,'MarkerFaceColor',DKL.RGBval(hue,:)./255);
end
title('Chromaticities in CIE space');
xlabel('X vals');
ylabel('Y vals');
axis square;

subplot(1,3,3)
plot(rad2deg(-HueAngles),DKL.cXvals,'ro-'); %
hold on;
plot(rad2deg(-HueAngles),DKL.cYvals,'go-'); %
plot(rad2deg(-HueAngles),DKL.cZvals,'bo-'); %
title('CIE chromaticities vs hue angle');
xlabel('Hue angle (deg)');
ylabel('Chromaticity value (CIE)');
axis square;

DataSave = CalLumInput('Save data? 0/1',0); %save data or no?

if DataSave
    fName = sprintf('%sMonitorData/DKLcolvals_%sLum_%sCon.mat',ThisDirectory,num2str(LV),num2str(ContrastVal));
    save(fName,'fName','DKL','HueAngles','LV','ContrastVal','WhichMonFile'); %save variables into .mat file to be re-loaded later
end

