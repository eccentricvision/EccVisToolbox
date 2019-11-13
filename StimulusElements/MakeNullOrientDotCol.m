function [NullOrient,LineInd,DotInd,CircInd]=MakeNullOrientDotCol(PatchSize,LineLen,LineWid,CircWid,DotRad,ori,cols,dotTop)
%function [NullOrient,LineInd,DotInd,CircInd]=MakeNullOrientDot(PatchSize,LineLen,LineWid,CircWid,DotRad,ori,cols)
% makes a 'no smoking' type null sign with a central dot - can judge orientation of line and alter circle/dot colours (pokeball?)
%
% J Greenwood 2012
%
% PatchSize = total, LineLen = length of lines, LineWid = width of lines, 
% CircWid = width of circle outline, TeeOr1/2 = relative orientation of horz/vert lines (in deg +/-90)
% cols = 4x3 array of RGB values for line,circle,dot,background
% returns NullOrient (image) and LineInd,CircInd,DotInd which index the pixels for each element
%
% [NullOrient,LineInd,DotInd,CircInd]=MakeNullOrientDotCol(155,55,11,3,13,18,[1 0 0; 0 0.4 0; 0 0.4 0; 0.5 0.5 0.5],1); imshow(NullOrient); %matched surface area version
% [NullOrient,LineInd,DotInd,CircInd]=MakeNullOrientDotCol(78,66,17,3,14,0,[1 0 0; 1 0 0; 1 0 0; 0 0 0],1); imshow(NullOrient); %matched area version

if ~exist('dotTop')
    dotTop=0; %dot goes behind the line
end

InCircRad  = LineLen/2; %inner radius of circle = teesize
OutCircRad = (LineLen/2)+CircWid; %outer radius of circle

%make a meshgrid
halfpx        = (PatchSize/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy        = (PatchSize/2)-0.5;
[meshX,meshY] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle

%make the line
HalfLen   = (LineLen/2)+1; %extend length a bit to avoid gaps with circle (not a visible increase otherwise)
HalfWid   = LineWid/2;
Horz      = zeros(PatchSize,PatchSize);
Horz(meshX>-HalfLen & meshX<HalfLen & meshY>-HalfWid & meshY<HalfWid) = 1;

%rotate line
LineR   = ImClip(imrotate(Horz,ori,'bilinear'),[PatchSize PatchSize]); %rotates each element
LineInd = logical(LineR); %convert to 0s & 1s

%make polar mesh
[meshTH,meshR]=cart2pol(meshX,meshY); %convert to polar coordinates

%make circle
outCirc = meshX.*0; %create blank array
outCirc(meshR<OutCircRad)=1; %draw 1s within rectangle boundaries
inCirc = meshX.*0; %create blank array
inCirc(meshR<InCircRad)=1; %draw 1s within rectangle boundaries

CircInd = logical(outCirc-inCirc);

%make dot
dotIm = meshX.*0; %create blank array
dotIm(meshR<DotRad+0.5)=1; %draw 1s within rectangle boundaries (add 0.5 to avoid rounding issues making too small)
if dotTop %dot goes on top of line
    DotInd = logical(dotIm);
else
    DotInd = logical(dotIm + LineR)-logical(LineR);
    DotInd  = (DotInd>0); %make sure only zeros and ones
end

NullOrient=zeros(PatchSize,PatchSize,3);
for cc=1:3 %make final colour image
    temp = (0.*meshX)+cols(4,cc); %background colour
    temp(LineInd) = cols(1,cc); %vert element
    temp(CircInd) = cols(2,cc); %circle
    temp(DotInd)  = cols(3,cc); %dot
    NullOrient(:,:,cc) = temp;
end
