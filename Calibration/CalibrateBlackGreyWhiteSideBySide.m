% CalibrateBlackGreyWhite
% function to measure the luminance/chromaticity values of black/mid-grey/white with a CRT (achromatic)
% use CalibrateGamma to measure the full gamma function - this is just three values
% J Greenwood April 17 2015, re-jigged July 2016

%% parameters & stimuli
BlackBG=1; %0/1 for black/grey background
if BlackBG
    BGcol = [0 0 0];
else %grey BG
    BGcol = [128 128 128];
end

% Image dimensions
imsize = 256;
p      = 3;

rgbImage=zeros(imsize,imsize,p);  % This will be our RGB stimulus

NoSamps=3;

V = [0 128 255];

%% initialise psychtoolbox and get screen details

AssertOpenGL;
Screen('Preference','SkipSyncTests',1); %we don't need these here and it increases generalisability of the code
screens=Screen('Screens');

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
Screen('FillRect',w, BGcol);%[128 128 128]); % this is grey - in Mono++ the blue carries the LUT index
vbl=Screen('Flip', w);

if ispc %might need to hide the taskbar5
    ShowHideWinTaskbarMex(0)
end

%% show the values side by side and then finish up

%size of source rectangle
srcRect = [0 0 imsize imsize];
%where to position the 3 blocks
centreX = [(screenRect(3)/2)-imsize (screenRect(3)/2) (screenRect(3)/2)+imsize];

%loop through and make the images
for vol=1:NoSamps
    rgbImage   = zeros(imsize,imsize,p)+V(vol); 
    imTex(vol) = Screen('MakeTexture', w, rgbImage);             % Make the image texture
    %make the destination rect for where the blocks will go on screen
    DestRect(vol,:) = [centreX(vol)-imsize/2 (screenRect(4)/2)-imsize/2 centreX(vol)+imsize/2 (screenRect(4)/2)+imsize/2];
end

% Draw all 3 textures at the same time
Screen('DrawTextures', w, imTex, srcRect, DestRect', 0);          
%flip the screen
vbl=Screen('Flip', w);

KbWait; %wait for a keypress
Screen('Close',imTex); %close the texture
Screen('CloseAll');

if ispc %might need to restore the taskbar
    ShowHideWinTaskbarMex(1)
end

