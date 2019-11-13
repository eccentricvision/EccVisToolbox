% CalibrateGamma
%im=floor(LR.LtoVfun(LR,stim)); %sample call to extract correct values
%(once run)

thisFile='CalibrateGamma.m';
ThisDirectory=which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));

AssertOpenGL;
screens=Screen('Screens');
screenNumber=max(screens)
[w screenRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);
%draw blank screen
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FillRect',w, [128 128 0]); % this is grey - in Mono++ the blue carries the LUT index
vbl=Screen('Flip', w);

%set up bitsbox clut
m=128; n=128; p=3;                                  % Image dimensions
rgbImage=zeros(m,n,p);                              % This will be the RGB stimulus
bitsPlusRect = [0     0   524     1];               % The window we  write the Bits++ CLUT into

NoSamps=16;
V=linspace(0,2^16-1,NoSamps);
tab1=repmat([1:256]',[1 3])./256  ;
Screen('LoadNormalizedGammaTable', w, tab1,1);

newClutRow = BitsPlusEncodeClutRow((2^16-1).*hsv(256));  % Encode CLUT  ('hsv') using PTB routine
clutText =Screen('MakeTexture', w, newClutRow);          % Make the  CLUT texture
Screen('DrawTexture', w, clutText, [], bitsPlusRect,0,0);
vbl=Screen('Flip', w);

for i=1:NoSamps
    RampImage=zeros(m,n)+V(i);
    rgbImage(:,:,1)=RampImage./256;                         % Write MSB  ramp into red...
    rgbImage(:,:,2)=mod(RampImage,256);                     % ... and LSB  ramp into green
    %rgbImage(:,:,3)=RampImage;
    imText =Screen('MakeTexture', w, rgbImage);             % Make the image texture
    Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures
    vbl=Screen('Flip', w);
    L(i) = CalLumInput('Enter luminance (cd/m2)',50);  % replace this with pause()
    Screen('Close',imText);
end
%L=[0.53 1.2 2.5 4.8 8.1 12.6 18 25 33.4 43 54 66.8 80 97 113 133];
Screen('FillRect',w, [128 128 0]); % this is grey - in Mono++ the blue carries the LUT index
vbl=Screen('Flip', w);

figure(1)
LR=SimpleFitPower(V,L);
defFname=DefInput('Where to save calibration file? ',sprintf('%s%c',ThisDirectory,'CalDataBits.mat'));
save(defFname,'LR')

linearLum=linspace(LR.LMin,LR.LMax,8);

for i=1:length(linearLum)
    theVoltage=floor(LR.LtoVfun(LR,linearLum(i)));
    rgbImage=theVoltage+0.*rgbImage;
    rgbImage(:,:,1)=rgbImage(:,:,1)./256;                         % Write MSB  ramp into red...
    rgbImage(:,:,2)=mod(rgbImage(:,:,1),256);                     % ... and LSB  ramp into green
    rgbImage(:,:,3)=zeros(size(rgbImage(:,:,3)));
    imText =Screen('MakeTexture', w, rgbImage);             % Make the image texture
    Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures
    vbl=Screen('Flip', w);
    Screen('Close',imText);
    newL(i) = CalLumInput('Enter luminance (cd/m2)',50);  % replace this with pause()
end
figure(2)
plot(linearLum,newL,'o',linearLum,linearLum,'-');

newClutRow = BitsPlusEncodeClutRow((2^16-1).*gray(256)); % Encode CLUT  ('hsv') using PTB routine (restore CLUT to grey values)
clutText = Screen('MakeTexture', w, newClutRow);
Screen('DrawTexture', w, clutText, [], bitsPlusRect,0,0);
vbl=Screen('Flip', w);
Screen('CloseAll')
