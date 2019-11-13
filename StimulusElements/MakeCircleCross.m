function [CircCross,HorzInd,VertInd,CircInd]=MakeCircleCross(PatchSize,TeeLen,TeeWid,CircWid,or1,or2)
%function [CircCross,HorzInd,VertInd,CircInd]=MakeCircleCross(PatchSize,TeeLen,TeeWid,CircWid,or1,or2)
% NB. no colour! Use MakeCircleCrossCol for colour. Removed xoff/yoff to add speed
%
%J Greenwood 2012
%
% PatchSize = total, TeeLen = length of lines, TeeWid = width of lines, 
% CircWid = width of circle outline, TeeOr1/2 = relative orientation of horz/vert lines (in deg +/-90 where -90 is CW)
% returns CircCross (image) and HorzInd,VertInd,CircInd which index the pixels for each element
%
% [CircCross,HorzInd,VertInd,CircInd]=MakeCircleCross(150,55,11,3,18,0); imshow(CircCross); %matched surface area version
% [CircCross,HorzInd,VertInd,CircInd]=MakeCircleCross(150,55,11,11,-5,0); imshow(CircCross); %matched width version

InCircRad  = TeeLen/2; %inner radius of circle = teesize
OutCircRad = (TeeLen/2)+CircWid; %outer radius of circle

%make a meshgrid
halfpx        = (PatchSize/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy        = (PatchSize/2)-0.5;
[meshX,meshY] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle

%make the lines
HalfLen   = (TeeLen/2)+1; %extend length a bit to avoid gaps with circle (not a visible increase otherwise)
HalfWid   = TeeWid/2;
Horz      = zeros(PatchSize,PatchSize);
Horz(meshX>-HalfLen & meshX<HalfLen & meshY>-HalfWid & meshY<HalfWid) = 1;
Vert      = Horz';

%rotate lines and combine
HorzR   = ImClip(imrotate(Horz,or1,'bilinear'),[PatchSize PatchSize]); %rotates each element
%HorzR   = ImShift(HorzR,Yoff.*(0.5*TeeLen),pi/2); %input is (image, npixels to shift, dirn to shift)
VertR   = ImClip(imrotate(Vert,or2,'bilinear'),[PatchSize PatchSize]);
%VertR   = ImShift(VertR,Xoff.*(0.5*TeeLen),pi);

HorzInd = logical(HorzR); %convert to 0s & 1s
VertInd = logical(VertR); 
%CrossIm = (HorzR)+(VertR); %adds elements together, converts to 0/1

%make polar mesh
[meshTH,meshR]=cart2pol(meshX,meshY); %convert to polar coordinates

%outer circle
outCirc = meshX.*0; %create blank array
outCirc(meshR<OutCircRad)=1; %draw 1s within rectangle boundaries
%inner circle
inCirc = meshX.*0; %create blank array
inCirc(meshR<InCircRad)=1; %draw 1s within rectangle boundaries

CircInd = logical(outCirc-inCirc);
%CircInd = logical(CircIm); %index for circle

CircCross=CircInd+HorzInd+VertInd; %add images/indices to make final image
CircCross(CircCross>1)=1;
