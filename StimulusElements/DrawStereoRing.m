function [ringLE,ringRE,LEind,REind,circInd,ringDX]=DrawStereoRing(patch,radOut,radIn,bgLum,ringcon,dotcon,pixscale,ringDX,crossed)
% [ringLE,ringRE,LEind,REind,circInd,ringDX]=DrawStereoRing(patch,radOut,radIn,bgLum,ringcon,dotcon,pixscale,ringDX,crossed)
% function to draw a ring or ring segment centred within a patch, in stereo
% patch = patch dimension (square); radOut = outer radius; radIn=inner radius, bgLum = background luminance; ringcon=contrast;
% dotcon = pixel contrast; pixscale = size of pixels (1=unscaled); ringDX = disparity between two images;
% crossed = 0/1 crossed disparity (0=uncrossed);
% returns LE image, RE image, indices for both rings and patch, plus final DX
%
%eg.  ringRad = 150; [ringLE,ringRE,LEind,REind,circInd,ringDX] = DrawStereoRing(round(ringRad*4),ringRad,ringRad-40,0,-0.5,0.5,2,15,1); figure; subplot(1,2,1); imshow(ringLE); subplot(1,2,2); imshow(ringRE)
%eg2. ringRad = 150; [ringLE,ringRE,LEind,REind,circInd,ringDX] = DrawStereoRing(round(ringRad*4),ringRad,ringRad-40,0.5,-0.5,0.5,2,15,1);RedBlue=zeros([size(ringLE) 3]);RedBlue(:,:,1)=ringLE*0.4;RedBlue(:,:,3)=ringRE;RedBlue(:,:,2)=zeros(size(ringLE));figure;imshow(RedBlue)
%
%J Greenwood 2014

ringDX   = round(ringDX); %round this value to avoid issues
pixscale = round(pixscale); %round this value to avoid issues
%bgLum     = 0.5;
angRange  = [0 360]; %always draw a full ring

if bgLum %if non-zero bg
    dotconCOR = (bgLum*dotcon); %multiply contrast with background luminance - for dots
    ringconCOR  = (bgLum*ringcon); %contrast increment for ring element
else
    dotconCOR = dotcon; %if background is zero, don't multply
    ringconCOR  = ringcon;
end
newRadOut = round(radOut./pixscale); %adjust parameters for later scaling up (to increase pixel size)
newRadIn = round(radIn./pixscale); %adjust parameters for later scaling up (to increase pixel size)
patch    = round(patch./pixscale);
squareIm = patch;%+2;
ringDX   = round(ringDX./pixscale);

%draw the ring
minAng=deg2rad(min(angRange)); %angles to plot
maxAng=deg2rad(max(angRange));
halfpx = round(patch/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy = round(patch/2)-0.5;

[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates
th(th<0)=th(th<0)+(2*pi);%th(th<180)=wrapTo2pi(th); %wrap to 0-360

circIm1 = meshpx.*0; %create blank array for outer circle
circIm1(r<newRadOut & (th>minAng & th<maxAng))=1; %draw 1s within rectangle boundaries for outer circle

circIm2 = meshpx.*0; %blank array for inner circle
circIm2(r<newRadIn & (th>minAng & th<maxAng))=1; %draw 1s within rectangle boundaries for inner circle

ringIm = (circIm1-circIm2); %make ring
ringInd = find(ringIm==1); %find location of ring pixels

[ringY,ringX]  = ind2sub(size(ringIm),ringInd); %y,x indices for ring image (to displace if needed)
halfDX   = round(ringDX/2); %half DX to apply to each eye to generate symmetric disparity
switch crossed
    case 1 %crossed / near disparities
        LEringX = ringX + halfDX;
        REringX = ringX - halfDX;
    case 0 %uncrossed / far disparities
        LEringX = ringX - halfDX;
        REringX = ringX + halfDX;
end
LEind = sub2ind(size(ringIm),ringY,LEringX); %convert x,y vals back to indices - report these back if no pixel re-scaling
REind = sub2ind(size(ringIm),ringY,REringX);

%generate random-dot set for correlated ring image and correct contrasts
bgcircle = DrawCirc((patch/2),[0 360],squareIm,squareIm); % draw circle for background
for rr=1:2 %generate two random pixel arrays - one as main image, the other to fill in shifted pixels
    ranpatch(:,:,rr) = (round(rand([squareIm squareIm]))-0.5)*2; %make random pixel grid of contrast values as background (could round if desired?) then subtract mean luminance to make -1 to 1
    if max(size(bgcircle))>max(size(ranpatch(:,:,rr)));
        bgcircle = imcrop(bgcircle,[1 1 size(ranpatch(:,:,rr))-1]); %if circle is larger - crop to image dimensions
    end
    ranpatch(:,:,rr) = ranpatch(:,:,rr).*bgcircle; %turns outer part to zero, keeps inner circle
    ranpatch(:,:,rr) = (ranpatch(:,:,rr).*dotconCOR)+bgLum; %adjust dots to desired contrast and add background
end
circInd        = bgcircle;
background     = ranpatch(:,:,1); %used as both background and initial set for ring generation
ranresample    = ranpatch(:,:,2); %give a single image for easier indexing - used to fill blank spots
%make LEimage
ringLE        = background;%(round(rand([patch patch]))-0.5)*2; %generate new random-dot set
ringLE(LEind) = background(ringInd)+ringconCOR; %add contrast increment to ring image if present
%ringLE(ringLE<0)= 0; ringLE(ringLE>1)=1; %rounding

%make REimage
ringRE        = background;%use same background as LE
if ringDX>0 %i.e. if depth is present
    ringRE(LEind) = ranresample(LEind); %fill in LE coordinates with random pixels from second ranpatch
end

ringRE(REind) = background(ringInd)+ringconCOR;% add contrast increment to ring image if present
%ringRE(ringRE<0)= 0; ringRE(ringRE>1)=1; %rounding
if pixscale~=1
    bg2 = ones(size(ringLE)); %make blank field of ones
    LEpix = bg2;
    LEpix(LEind)=LEpix(LEind).*0; %make stencil outline of LEpixels
    REpix = bg2;
    REpix(REind)=REpix(REind).*0;
    LEpix = round(imresize(LEpix,pixscale,'box','Antialiasing',0)); %re-scale stencil images and round to 0/1
    REpix = round(imresize(REpix,pixscale,'box','Antialiasing',0));
    clear LEind; clear REind;
    LEind = find(LEpix==0); %re-scaled indices for LE image
    REind = find(REpix==0);
    
    ringLE  = imresize(ringLE,pixscale,'box','Antialiasing',0);
    ringRE  = imresize(ringRE,pixscale,'box','Antialiasing',0);
    circInd = round(imresize(circInd,pixscale,'box','Antialiasing',0));
end
