%function MonoPlusGray%% Put a gray ramp in the Bits++ box (in Mono++ mode) overlaid with a  natty coloured ramp% Requires the Bits++ toolbox for 'BitsPlusEncodeClutRow'% Run it, hit a key to end.%% History% 29/01/04  Steven Dakin wrote it.% 15/03/04  SCD expanded it to be PC compatible% 02/06/06  SCD converted to the openGL toolbox% 22/08/06  SCD updated it for latest PTB on Macs & PCs. Cosmetics  applied.%AssertOpenGL;screens=Screen('Screens');screenNumber=1;%max(screens);%str2double(inputdlg('Which  screen?','Screen for demo',1,{num2str(max(screens))})); % % edit as  you see fitScreen('Preference','SkipSyncTests', 1);[w screenRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);Screen('FillRect',w, [128 128 0]); % this is grey - in Mono++ the  blue carriesthe LUT indexvbl=Screen('Flip', w);m=512; n=512; p=3;                                  % Image dimensionsrgbImage=zeros(m,n,p);                              % This will be  our RGB stimulusbitsPlusRect = [0     0   524     1];               % The window we  write the Bits++ CLUT into% Scaling grey levels. We generate a 14-bit value: the 8 most  significant% bits (MSBs) go into the red part of the image, the 6 Least  significant bits% go into the green (the two other bits being set to zero). To do  this: scale% grey levels 0 to (2^16)-1. Divide by 256 to get MSB, mod(x,256) for  LSB. RampImage=ones(m,n)*((2^16)-1);    % Make left- right luminance-ramp image 0 to 2^16-1rgbImage(:,:,1)=RampImage./256;                         % Write MSB  ramp into red...rgbImage(:,:,2)=mod(RampImage,256);                     % ... and LSB  ramp into green% Make the central coloured rampsX=256;%rgbImage(m/2-sX/2:m/2+sX/2-1,n/2-sX/2:n/2+sX/2-1,1:2)= 0;        % Make a  "hole" in the Red and Green channels[X,Y]=meshgrid([1:sX],[1:sX]);rgbImage(m/2-sX/2:m/2+sX/2-1,n/2-sX/2:n/2+sX/2-1,3)  =0;%rgbImage(m/2-128:m/2+127,n/2-128:n/2+127,3)  = repmat(linspace (1,256,256),[256 1])'; % then a horiz. ramp in blueimText =Screen('MakeTexture', w, rgbImage);              % Make the  image texturenewClutRow = BitsPlusEncodeClutRow((2^16-1).*hsv(256));  % Encode CLUT  ('hsv') using PTB routineclutText =Screen('MakeTexture', w, newClutRow);          % Make the  CLUT texturetab1=repmat([1:256]',[1 3])./256  ;Screen('LoadNormalizedGammaTable', w, tab1,1);Screen('DrawTexture', w, imText, [], [], 0);             % Draw all  texturesScreen('DrawTexture', w, clutText, [], bitsPlusRect,0,0);vbl=Screen('Flip', w);Screen('DrawTexture', w, imText, [], [], 0);             % Draw all  texturesScreen('DrawTexture', w, clutText, [], bitsPlusRect,0,0);pauseScreen('Close',clutText);newClutRow = BitsPlusEncodeClutRow((2^16-1).*gray(256)); % Encode CLUT  ('hsv') using PTB routineclutText = Screen('MakeTexture', w, newClutRow);Screen('DrawTexture', w, clutText, [], bitsPlusRect,0,0);vbl=Screen('Flip', w);Screen('CloseAll');       % Finish up