function [circLE,circRE,LEind,REind] = DrawRandotCircle(circRad,patchYX,elCon,dotCon,circDX,depthsign,pixscale)
%function to draw a circle made of random pixels, with or without a contrast increment added on
%circRad = radius of target circle; patch = background patch size Y then X; elCon = Circle Contrast Increment; dotCon = contrast of pixel elements;
%circDX = disparity between two images; %depthsign =-1/1 (1=crossed/near disparity; -1=uncrossed/far); pixscale = size of pixels (1=unscaled)
%
%J Greenwood Nov 2022
%
% e.g. circRad = 150; [circLE,circRE,LEind,REind] = DrawRandotCircle(circRad,[round(circRad*4) round(circRad*4)],-0.5,0.5,15,1,4); figure; subplot(1,2,1); imshow(circLE); subplot(1,2,2); imshow(circRE); RedGreen=zeros([size(circLE) 3]);RedGreen(:,:,1)=circRE;RedGreen(:,:,2)=circLE;figure;imshow(RedGreen)

bgLum     = 0.5; %background must be mean luminance to allow randot variation
if bgLum %if non-zero bg
    dotConCOR = (bgLum*dotCon); %multiply contrast with background luminance - for dots
    elConCOR  = (bgLum*elCon); %contrast increment for circ element
else
    dotConCOR = dotCon; %if background is zero, don't multply
    elConCOR  = elCon;
end
circRad    = round(circRad./pixscale); %adjust parameters for later scaling up (to increase pixel size)
patchSizeX = round(patchYX(2)./pixscale);
patchSizeY = round(patchYX(1)./pixscale);
circDX     = round(circDX./pixscale);

circ = 1-DrawCirc(circRad,[0 360],patchSizeX,patchSizeY); %draw circ with black contrast on white background, no colour, other variables specified
circTemp = circ(:,:,1); %strip 3 layer image to just take first layer
circInd = find(circTemp==0); %find location of circ body pixels

[gY,gX]  = ind2sub(size(circTemp),circInd); %y,x indices for circ image (to displace if needed)
halfDX   = round(circDX/2); %half DX to apply to each eye to generate symmetric disparity
switch depthsign
    case -1 %uncrossed / far disparities
        LEgX = gX - halfDX;
        REgX = gX + halfDX;
    case 1 %crossed / near disparities
        LEgX = gX + halfDX;
        REgX = gX - halfDX;
end
LEind = sub2ind(size(circTemp),gY,LEgX); %convert x,y vals back to indices - report these back if no pixel re-scaling
REind = sub2ind(size(circTemp),gY,REgX);

%generate random-dot set for correlated circ image and correct contrasts
ranpatch = [];% = DrawCirc((patch/2),[0 360],squareImX,squareImY); % draw rectangle for background
for rr=1:2 %generate two random pixel arrays - one as main image, the other to fill in shifted pixels
    ranpatch(:,:,rr) = (round(rand([patchSizeY patchSizeX]))-0.5)*2; %make random pixel grid of contrast values as background (could round if desired?) then subtract mean luminance to make -1 to 1
    ranpatch(:,:,rr) = (ranpatch(:,:,rr).*dotConCOR)+bgLum; %adjust dots to desired contrast and add background
end
background     = ranpatch(:,:,1); %used as both background and initial set for circ generation
ranresample    = ranpatch(:,:,2); %give a single image for easier indexing - used to fill blank spots
%make LEimage
circLE        = background;%(round(rand([patch patch]))-0.5)*2; %generate new random-dot set
circLE(LEind) = background(circInd)+elConCOR; %add contrast increment to circ image if present
circLE(circLE<0)= 0; circLE(circLE>1)=1; %rounding
%make REimage
circRE        = background;%use same background as LE
circRE(LEind) = ranresample(LEind); %fill in LE coordinates with random pixels from second ranpatch

circRE(REind) = background(circInd)+elConCOR;% add contrast increment to circ image if present
circRE(circRE<0)= 0; circRE(circRE>1)=1; %rounding
if pixscale~=1
    bg2 = ones(size(circLE)); %make blank field of ones
    LEpix = bg2;
    LEpix(LEind)=LEpix(LEind).*0; %make stencil outline of LEpixels
    REpix = bg2;
    REpix(REind)=REpix(REind).*0;
    LEpix = round(imresize(LEpix,pixscale,'box','Antialiasing',0)); %re-scale stencil images and round to 0/1
    REpix = round(imresize(REpix,pixscale,'box','Antialiasing',0)); 
    clear LEind; clear REind;
    LEind = find(LEpix==0); %re-scaled indices for LE image
    REind = find(REpix==0);
    
    circLE = imresize(circLE,pixscale,'box','Antialiasing',0);
    circRE = imresize(circRE,pixscale,'box','Antialiasing',0);
end
