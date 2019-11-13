function [CircCross,HorzInd,VertInd,CircInd]=MakeCircleCrossCol(PatchSize,TeeLen,TeeWid,CircWid,Xoff,Yoff,or1,or2,cols)
%function [CircCross,HorzInd,VertInd,CircInd]=MakeCircleCrossCol(PatchSize,TeeLen,TeeWid,CircWid,Xoff,Yoff,or1,or2,cols)
%
%J Greenwood 2012
%
% PatchSize = total, TeeLen = length of lines, TeeWid = width of lines, 
% CircWid = width of circle outline, Xoff = x-offset of horz line (+/-1), Yoff = y-offset of Vert line (+/-1), 
% TeeOr1/2 = relative orientation of horz/vert lines (in deg +/-90), cols = 4x3 array of RGB values for Horz,Vert,Circle lines,background
% returns CircCross (image) and HorzInd,VertInd,CircInd which index the pixels for each element
%
% [CircCross,HorzInd,VertInd,CircInd]=MakeCircleCrossCol(150,55,11,3,0,0,18,0,[1 1 1; 1 1 1; 1 0 0; 0.5 0.5 0.5]); imshow(CircCross); %matched surface area version
% [CircCross,HorzInd,VertInd,CircInd]=MakeCircleCrossCol(150,55,11,11,0,0,-18,0,[1 0 0; 0 1 0; 0 1 0; 0.5 0.5 0.5]); imshow(CircCross); %matched width version

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
HorzR   = ImShift(HorzR,Yoff.*(0.5*TeeLen),pi/2); %input is (image, npixels to shift, dirn to shift)
VertR   = ImClip(imrotate(Vert,or2,'bilinear'),[PatchSize PatchSize]);
VertR   = ImShift(VertR,Xoff.*(0.5*TeeLen),pi);

HorzInd = logical(HorzR); %convert to 0s & 1s
VertInd = logical(VertR); 

CrossIm = (HorzR)+(VertR); %adds elements together

%make polar mesh
[meshTH,meshR]=cart2pol(meshX,meshY); %convert to polar coordinates

%outer circle
outCirc = meshX.*0; %create blank array
outCirc(meshR<OutCircRad)=1; %draw 1s within rectangle boundaries
%inner circle
inCirc = meshX.*0; %create blank array
inCirc(meshR<InCircRad)=1; %draw 1s within rectangle boundaries

CircIm  = outCirc-inCirc;
CircInd = logical(CircIm); %index for circle

CircCross=zeros(PatchSize,PatchSize,3);
for cc=1:3 %make final colour image
    temp = (0.*CircIm)+cols(4,cc); %background colour
    temp(VertInd) = cols(2,cc); %vert element
    temp(HorzInd) = cols(1,cc); %horz element
    temp(CircInd) = cols(3,cc); %circle
    CircCross(:,:,cc) = temp;
end
