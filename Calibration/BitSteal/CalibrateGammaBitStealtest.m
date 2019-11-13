% CalibrateGammaBitSteal
%im=floor(LR.LtoVfun(LR,stim)); %sample call to extract correct values
%(once run)

thisFile='CalibrateGammaBitSteal.m';
ThisDirectory=which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));
%% setup

AssertOpenGL;
screens=Screen('Screens');
screenNumber=max(screens)
[w screenRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FillRect',w, [128 128 128]); % this is grey - in Mono++ the blue carries the LUT index
vbl=Screen('Flip', w);
 
%% first calibrate max range
%set B:R:G = 1:2:4
%max out blue guns and calibrate
%then set R to be twice that
%then G as twice again

m=750; n=750; p=3;                                  % Image dimensions
rgbImage=zeros(m,n,p);                              % This will be our stimulus
rgbImage(1:250,1:250,:) = rgbImage(1:250,1:250,:)+255;
rgbImage(1:250,251:500,:) = rgbImage(1:250,251:500,:);
rgbImage(1:250,501:750,1) = rgbImage(1:250,501:750,1)+255;
rgbImage(251:500,1:250,2) = rgbImage(251:500,1:250,2)+255;
rgbImage(251:500,251:500,3) = rgbImage(251:500,251:500,3)+255;
rgbImage(251:500,501:750,1) = rgbImage(251:500,501:750,1)+127;
rgbImage(501:750,1:250,2) = rgbImage(501:750,1:250,2)+127;
rgbImage(501:750,251:500,3) = rgbImage(501:750,251:500,3)+127;
rgbImage(501:750,501:750,:) = rgbImage(501:750,501:750,:)+127;
 
imText =Screen('MakeTexture', w, rgbImage);             % Make the image texture
         Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures
         vbl=Screen('Flip', w);
         MaxVal = DefInput('Photometer Val?',0);
Screen('Close',imText);

