function [LEim,REim,LEind,REind]=DrawStereoSplitCircOutline(patchsize,circRad,gapwidth,circwidth,DX,crossed,whichEl,bgLum,elLum)
%[LEim,REim,LEind,REind] = DrawStereoSplitCircOutline(patchsize,circRad,gapwidth,circwidth,DX,crossed,whichEl,bgCon,elCon)
%function to draw two half-circles separated by a gap, centred within a patch
%one is offset with a certain disparity, the other either LE only, RE only or dichoptic
%patchsize = patch dimensions, circRad = radius of half-circles, gapwidth = separation, circwidth = line width;
% DX = disparity in pixels, crossed= 0/1 near or far disparity,
%whichEl = [1 2 3 4] where 1=depth, 2=dichoptic, 3=LE only, 4=RE only, 5 = random x shift dichoptic
%can have any combination of these whichEl options as long as each half has a number, e.g. [5 1] or [1 2]
% bgLum = bg luminance 0-1 (but 0.5 is best), elLum = element luminance 0 to 1 with two numbers e.g. [0 0.75];
% rotate = 0 always where 0 is horizontal gap line
%e.g. [LEim,REim,LEind,REind] = DrawStereoSplitCircOutline(400,80,20,20,8,1,[2 1],0.5,[0 1]);circIm=zeros(400,400,3); circIm(:,:,1) = LEim*0.6; circIm(:,:,3) = REim; imshow(circIm);
% or  [LEim,REim,LEind,REind] = DrawStereoSplitCircOutline(400,80,20,20,15,1,[2 1],0.5,[1 0]);circIm=zeros(400,400,3); circIm(:,:,1) = LEim*0.6; circIm(:,:,3) = REim; imshow(circIm);
% or  [LEim,REim,LEind,REind] = DrawStereoSplitCircOutline(400,80,20,20,15,0,[1 5],0.5,[0 1]);circIm=zeros(400,400,3); circIm(:,:,1) = LEim*0.6; circIm(:,:,3) = REim; imshow(circIm);
%J Greenwood 2014

halfpx = round(patchsize/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy = round(patchsize/2)-0.5;

[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates
th = flipud(th); %so that 0 points right and progression is CCW
th(th<0)=th(th<0)+(2*pi);%th(th<180)=wrapTo2pi(th); %wrap to 0-2*pi

absX = abs(meshpx);
absY = abs(meshpy);

circOuter = circRad+(0.5*gapwidth); %outer radius
circInner = circRad+(0.5*gapwidth)-circwidth; %inner radius
lineOuter = (0.5*gapwidth) +circwidth; %absolute distance from centre to outer straight line
lineInner = (0.5*gapwidth); %absolute distance

circInd = zeros(size(meshpx)); %create image of ones where the sectors are - first sector = top
circInd((th>0 & th<pi) & (r>circInner & r<circOuter) & absY>lineInner)           = 1; %first sector (top)
circInd((th>0 & th<pi) & r<circOuter & (absY>lineInner & absY<lineOuter))        = 1; %first sector straight line (top)
circInd((th>pi & th<(2*pi)) & (r>circInner & r<circOuter) & absY>(0.5*gapwidth)) = 2; %mark out second sector (bottom)
circInd((th>pi & th<(2*pi)) & r<circOuter & (absY>lineInner & absY<lineOuter))   = 2; %second sector straight line (bottom)
%circInd = round(imrotate(circInd,-45,'nearest','crop'));

DXshift = (round(DX/2));
if crossed %near
    LEdx    = (whichEl==1)*DXshift;
    REdx    = (whichEl==1)*-DXshift;
else %uncrossed/far
    LEdx    = (whichEl==1)*-DXshift;
    REdx    = (whichEl==1)*DXshift;
end
whichRan    = (whichEl==5); %how many elements to be randomly x-shifted in both eyes
if sum(whichRan) %if any are to be randomly shifted in each eye
    RanSign = sign(rand(1,2)-0.5); %random sign for each of the randomly shifted elements
    rnshift = rand(1,1);
    LEdx    = LEdx + (whichEl==5).*(rnshift*(circOuter/2)*RanSign);
    REdx    = REdx + (whichEl==5).*(rnshift*(circOuter/2)*RanSign);
end
LEon    = (whichEl~=4); %all but RE
REon    = (whichEl~=3); %all but LE

LEind = zeros(size(meshpx));
REind = zeros(size(meshpx));
for halfc=1:2
    whichSect = (circInd==halfc);
    LEind = LEind + (ImShift(whichSect,LEdx(halfc),deg2rad(180))).*LEon(halfc);
    REind = REind + (ImShift(whichSect,REdx(halfc),deg2rad(180))).*REon(halfc);
end

upperInd  = find(meshpy<0);
lowerInd  = find(meshpy>0);
LEind2    = find(LEind==1);
REind2    = find(REind==1);

LEupper   = intersect(upperInd,LEind2);
LElower   = intersect(lowerInd,LEind2);
REupper   = intersect(upperInd,REind2);
RElower   = intersect(lowerInd,REind2);

LEim = ones(size(meshpx)).*bgLum;
if sum(LEupper) %avoids empty array errors
    LEim(LEupper) = elLum(1);
end
if sum(LElower)
    LEim(LElower) = elLum(2);
end
REim = ones(size(meshpx)).*bgLum;
if sum(REupper)
    REim(REupper) = elLum(1);
end
if sum(RElower)
    REim(RElower) = elLum(2);
end




