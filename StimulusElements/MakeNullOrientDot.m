function [NullOrient,LineInd,DotInd,CircInd]=MakeNullOrientDot(PatchSize,LineLen,LineWid,CircWid,DotRad,ori,dotTop)
%function [NullOrient,LineInd,DotInd,CircInd]=MakeNullOrientDot(PatchSize,LineLen,LineWid,CircWid,DotRad,ori,dotTop)
% makes a 'no smoking' type null sign with a central dot - can judge orientation of line and alter circle/dot colours
%
% J Greenwood 2012
%
% PatchSize = total, LineLen = length of lines, LineWid = width of lines,
% CircWid = width of circle outline, TeeOr1/2 = relative orientation of horz/vert lines (in deg +/-90), dotTop = 0/1 central dot on top or behind?
% returns CircCross (image) and HorzInd,VertInd,CircInd which index the pixels for each element
%
% [NullOrient,LineInd,DotInd,CircInd]=MakeNullOrientDot(150,55,11,3,13,18,0); imshow(NullOrient); %matched surface area version
% [NullOrient,LineInd,DotInd,CircInd]=MakeNullOrientDot(150,55,11,11,11,-5,1); imshow(NullOrient); %matched width version

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
HalfWid   = (LineWid/2);
Horz      = zeros(PatchSize,PatchSize);
Horz(meshX>-HalfLen & meshX<HalfLen & meshY>-HalfWid & meshY<HalfWid) = 1;

%rotate line
LineR   = imrotate(Horz,ori,'crop'); %rotates each element

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
dotIm(meshR<DotRad+0.5)=1; %draw 1s within rectangle boundaries (add 0.5 to avoid rounding issues making dot too small)

%final image
NullOrient=CircInd+LineR+logical(dotIm); %add images/indices to make final image
NullOrient(NullOrient>1)=1;

%final dot/line indices
if dotTop %dot goes on top of line
    DotInd = logical(dotIm);
    LineInd = logical(NullOrient-DotInd-CircInd); %convert to 0s & 1s
else
    LineInd = logical(CircInd+LineR)-CircInd; %convert to 0s & 1s
    DotInd = logical(dotIm + LineR)-LineR;
    LineInd = (LineInd>0);
    DotInd  = (DotInd>0); %make sure only zeros and ones
end


