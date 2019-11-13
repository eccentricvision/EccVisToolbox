% CalibrateGamma
% function to calibrate the gamma of a CRT (achromatic)
% v3.0 written nicely by J Greenwood July 2015, based on code from S Dakin way back when

%% options to begin

clear all;
commandwindow; %bring the cursor to the command window
Use3Dmode = 0;%DefInput('Use 3D mode? 0/1',0); %0/1 for 3D mode e.g. on Asus VG278 -
blackout  = DefInput('Blackout main monitor? 0/1',0);

%% set up the images / values to be tested

%determine the colour of the background during calibration - recommend black
BlackBG=1;
if BlackBG
    BGcol = [0 0 0];
else %grey BG
    BGcol = [128 128 128];
end

%Image dimensions
m=128;
n=128;
p=3;

% Create a blank array for what will be our RGB stimulus
TestImage=zeros(m,n,p);

%Luminance values
NoSamps = 16; %how many samples to measure
V       = linspace(0,2^8-1,NoSamps); %voltage range to measure (between 0-255)
%tab1    = repmat([1:256]',[1 3])./256  ;

%% initialise psychtoolbox & get screen settings

AssertOpenGL; %needed for the psychtoolbox
Screen('Preference','SkipSyncTests',1); %we don't need these here and it increases generalisability of the code
screens=Screen('Screens'); %get the monitor handle(s)

if numel(screens)>1
    if ispc %PCs number the monitors differently than macs
        blkScreen   = 2;
    else
        blkScreen = max(screens);
    end
    if blackout  %black out main monitor
        [w2 screenRect2]=Screen('OpenWindow',screens(blkScreen),0,[],32,2); %get Reference and resolution for main monitor
        blackim=zeros(screenRect2(3),screenRect2(4));
        Screen('FillRect',w2, [0 0 0]);
        Screen('Flip', w2); %black out the main screen
    end
end

if ispc %use screen 1 (since screens(1) is an extended window in PCs)
    screenNumber=screens(3);
else %use max screens for mac (unless you want the opposite here - then use screens(1);
    screenNumber=max(screens);
end

if Use3Dmode
    [w screenRect]=Screen('OpenWindow',screenNumber, 0,[],32,2,1); %final number gives stereomode = 1 (shutters)
else
    [w screenRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);
end

Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %set up alpha blending for psychtoolbox
Screen('FillRect',w, BGcol);%fill the background with your chosen colour
vbl=Screen('Flip', w);%present it

if ispc %might need to hide the taskbar - adds luminance when it's present
    ShowHideWinTaskbarMex(0);
end

%% run the calibration

%Screen('LoadNormalizedGammaTable', w, tab1,1);

for i=1:NoSamps
    TestImage = zeros(m,n,p)+V(i);
    imTex     = Screen('MakeTexture', w, TestImage);            % Make the image texture
    
    Screen('DrawTexture', w, imTex, [], [], 0);            % Draw the texture in screen centre
    
    vbl  = Screen('Flip', w); %flip the screen
    L(i) = DefInput('Enter luminance (cd/m2)',50);  % wait for response
    
    Screen('Close',imTex); %close the texture
end

Screen('FillRect',w, BGcol);%fill the background to end
vbl=Screen('Flip', w);

%% plot and save the function

figure
LR=SimpleFitPower(V,L); %fit the gamma function and generate the LR structure that we'll later use for all calibration

%find out where the code is to get directory
thisFile      = 'CalibrateGamma.m';
ThisDirectory = which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));
fN            = 'CalData.mat';%give the file a name (separate for each monitor you need to test on)

%prompt to check you want to save this file here - otherwise re-write the string
defFname = DefInput('Where to save calibration file? ',sprintf('%s%c',ThisDirectory,fN));
save(defFname,'LR'); %save the LR structure

%% check the calibration

linearLum=linspace(LR.LMin,LR.LMax,8);

for i=1:length(linearLum)
    CorrectedVoltage = floor(LR.LtoVfun(LR,linearLum(i)));
    TestImage        = CorrectedVoltage+zeros(m,n,p);
    imTex            = Screen('MakeTexture', w, TestImage);             % Make the image texture
    
    Screen('DrawTexture', w, imTex, [], [], 0);            % Draw the texture
    
    vbl     = Screen('Flip', w);
    newL(i) = DefInput('Enter luminance (cd/m2)',50);% wait for response
    
    Screen('Close',imTex);  %close the texture
    
end

%% plot the corrected luminance values

figure
plot(linearLum,newL,'o',linearLum,linearLum,'-');
xlabel('Desired luminance (cd/m2)');
ylabel('Measured luminance (cd/m2)');

Screen('CloseAll'); %shut down the psychtoolbox textures

if ispc %might need to restore the taskbar if you're on a windows machine
    ShowHideWinTaskbarMex(1)
end

