function [LEim,REim]=DrawStereoQuadrants(patchsize,circRad,gapwidth,DX,crossed,whichEl)
%quadIm = DrawStereoQuadrants(patchsize,circRad,gapwidth,DX,crossed,whichEl)
%function to draw four quadrants separated by a gap, centred within a patch
%one is offset with a certain disparity, one is LE only, one RE only, and one dichoptic
%patchsize = patch dimensions, circRad = radius of quadrants, gapwidth = separation,
% DX = disparity in pixels, crossed= 0/1 near or far disparity,
%whichEl = [1 2 3 4] where 1=depth, 2=dichoptic, 3=LE only, 4=RE only, 5 = random x shift dichoptic
%can have any combination of these whichEl options as long as each sector has a number, e.g. [5 5 5 3] or [1 2 2 2]
% rotate = 45 always where 0 is cardinal gap lines
%e.g. [LEim,REim] = DrawStereoQuadrants(200,80,20,8,1,[2 1 3 4]);quadIm=zeros(200,200,3); quadIm(:,:,1) = LEim*0.3; quadIm(:,:,3) = REim; imshow(quadIm);
% or  [LEim,REim] = DrawStereoQuadrants(200,80,20,12,1,[2 2 1 2]);quadIm=zeros(200,200,3); quadIm(:,:,1) = LEim*0.3; quadIm(:,:,3) = REim; imshow(quadIm);
% or  [LEim,REim] = DrawStereoQuadrants(200,80,20,15,0,[1 5 5 5]);quadIm=zeros(200,200,3); quadIm(:,:,1) = LEim*0.3; quadIm(:,:,3) = REim; imshow(quadIm);
%J Greenwood 2014

halfpx = round(patchsize/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy = round(patchsize/2)-0.5;

[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates
th = fliplr(th); %so that 0 points right and progression is CCW
%th(th<0)=th(th<0)+(2*pi);%th(th<180)=wrapTo2pi(th); %wrap to 0-2*pi

absX = abs(meshpx);
absY = abs(meshpy);

quadIm = zeros(size(meshpx)); %create blank array for one sector
quadIm(r<circRad+(0.5*gapwidth) & absX>(0.5*gapwidth) & absY>(0.5*gapwidth))=1; %draw 1s within sector boundaries

quadIm = round(imrotate(quadIm,-45,'bilinear','crop'));

quadInd = zeros(size(meshpx)); %create image of ones where the sectors are - first sector = right
quadInd((th>-pi & th<(-pi/2)) & r<circRad+(0.5*gapwidth) & absX>(0.5*gapwidth) & absY>(0.5*gapwidth)) = 1; %first sector (right)
quadInd((th>(-pi/2) & th<0)   & r<circRad+(0.5*gapwidth) & absX>(0.5*gapwidth) & absY>(0.5*gapwidth)) = 2; %mark out second sector (up)
quadInd((th>0 & th<(pi/2)) & r<circRad+(0.5*gapwidth) & absX>(0.5*gapwidth) & absY>(0.5*gapwidth)) = 3;%third sector (left)
quadInd((th>(pi/2) & th<pi) & r<circRad+(0.5*gapwidth) & absX>(0.5*gapwidth) & absY>(0.5*gapwidth)) = 4;%fourth (down)
quadInd = round(imrotate(quadInd,-45,'nearest','crop'));

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
    RanSign = sign(rand(1,4)-0.5); %random sign for each of the randomly shifted elements
    LEdx    = LEdx + (whichEl==5).*(DXshift*RanSign);
    REdx    = REdx + (whichEl==5).*(DXshift*RanSign);
end
LEon    = (whichEl~=4); %all but RE
REon    = (whichEl~=3); %all but LE

LEim = zeros(size(meshpx));
REim = zeros(size(meshpx));
for sect=1:4
    whichSect = (quadInd==sect);
    LEim = LEim + (ImShift(whichSect,LEdx(sect),deg2rad(180))).*LEon(sect);
    REim = REim + (ImShift(whichSect,REdx(sect),deg2rad(180))).*REon(sect);
end




