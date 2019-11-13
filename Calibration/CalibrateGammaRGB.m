% CalibrateGammaRGB
% function to calibrate the gamma of a CRT (separately for each RGB gun)
% made by S Dakin for luminance, modified J Greenwood 2012 for colour, 2015 for DKL calculations

thisFile='CalibrateGammaRGB.m';
ThisDirectory=which(thisFile); ThisDirectory=ThisDirectory(1:end-length(thisFile));

BlackBG=1;
if BlackBG
    BGcol = [0 0 0];
else %grey BG
    BGcol = [128 128 128];
end

AssertOpenGL;
screens=Screen('Screens');
screenNumber=max(screens);
[w screenRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FillRect',w, BGcol);%[128 128 128]); % this is grey - in Mono++ the blue carries the LUT index
vbl=Screen('Flip', w);

m=128; n=128; p=3;                                  % Image dimensions
rgbImage=zeros(m,n,p);                              % This will be our RGB stimulus

NoSamps=16;
V=linspace(0,2^8-1,NoSamps);
tab1=repmat([1:256]',[1 3])./256  ;
Screen('LoadNormalizedGammaTable', w, tab1,1);

cols = [1 0 0; 0 1 0; 0 0 1]; %R G B
labs = {'Red','Green','Blue'};

for cc=1:3
    clear L;
    disp('********'); disp(''); disp(labs(cc)); disp('********'); disp('');
    for i=1:NoSamps
        RampImage=zeros(m,n)+V(i);
        for col=1:3
            rgbImage(:,:,col)=RampImage.*cols(cc,col);
        end
        imText =Screen('MakeTexture', w, rgbImage);             % Make the image texture
        Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures
        vbl=Screen('Flip', w);
        L(i) = CalLumInput('Enter luminance (cd/m2)',i*7);  % replace this with pause()
        Screen('Close',imText);
    end
    %L=[0.53 1.2 2.5 4.8 8.1 12.6 18 25 33.4 43 54 66.8 80 97 113 133];
    Screen('FillRect',w, BGcol); % this is grey - in Mono++ the blue carries the LUT index
    vbl=Screen('Flip', w);
    
    figure
    Ltemp{cc}=SimpleFitPower(V,L);
    
    %now get chromaticity values at 50% luminance - needed to calculate values for DKL space
    theVoltage=floor(Ltemp{cc}.LtoVfun(Ltemp{cc},(Ltemp{cc}.LMax./2)));
    for col=1:3
        rgbImage(:,:,col)=(theVoltage+0.*rgbImage(:,:,col)).*cols(cc,col);
    end
    %RampImage=zeros(m,n)+128; %get colour with each gun independently at 50% luminance
    %for col=1:3
    %    rgbImage(:,:,col)=RampImage.*cols(cc,col);
    %end
    imText =Screen('MakeTexture', w, rgbImage);             % Make the image texture
    Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures
    vbl=Screen('Flip', w);
    Ltemp{cc}.chromaX      = CalLumInput('Enter chromaticity x-value',0.5);
    Ltemp{cc}.chromaY      = CalLumInput('Enter chromaticity y-value',0.5);
    Ltemp{cc}.chromaL0     = CalLumInput('Enter chromaticity luminance (cd/m2)',50);
    Ltemp{cc}.chromaLumVal = (Ltemp{cc}.LMax./2); %luminance value at which measurements were taken (should be mean luminance for that gun)
    
    Screen('Close',imText);
end

%save gamma correction functions & chromaticity values
Lred   = Ltemp{1};
Lgreen = Ltemp{2};
Lblue  = Ltemp{3};

WhereRU  = DefInput('Where are you? 1=Lab 2=Office? 3=CinemaHD 4=Elsewhere',4);
if WhereRU==1
    fN = 'LabCalDataRGB.mat';
elseif WhereRU==2
    fN = 'OfficeCalDataRGB.mat';
elseif WhereRU==3
    fN = 'CinemaHDcaldataRGB.mat';
else
    fN = 'CalDataRGB.mat';
end
defFname = DefInput('Where to save calibration file? ',sprintf('%s%c',ThisDirectory,fN));
save(defFname,'Lred','Lgreen','Lblue')

for cc=1:3
    linearLum=linspace(Ltemp{cc}.LMin,Ltemp{cc}.LMax,8);
    disp(labs(cc));
    for i=1:length(linearLum)
        theVoltage=floor(Ltemp{cc}.LtoVfun(Ltemp{cc},linearLum(i)));
        for col=1:3
            rgbImage(:,:,col)=(theVoltage+0.*rgbImage(:,:,col)).*cols(cc,col);
        end
        imText =Screen('MakeTexture', w, rgbImage);             % Make the image texture
        Screen('DrawTexture', w, imText, [], [], 0);            % Draw all textures
        vbl=Screen('Flip', w);
        Screen('Close',imText);
        newL(i) = CalLumInput('Enter luminance (cd/m2)',50);  % replace this with pause()
    end
    figure
    plot(linearLum,newL,'o',linearLum,linearLum,'-');
end

Screen('CloseAll')
