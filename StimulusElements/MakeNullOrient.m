function [NullOrient,LineInd,CircInd]=MakeNullOrient(PatchSize,LineLen,LineWid,CircWid,ori)
%function [NullOrient,LineInd,CircInd]=MakeNullOrient(PatchSize,LineLen,LineWid,CircWid,ori)
% makes a 'no smoking' type null sign (with no central dot) - can judge orientation of line and alter circle/line colours
%
% J Greenwood 2012
%
% PatchSize = total, LineLen = length of lines, LineWid = width of lines, 
% CircWid = width of circle outline, ori = relative orientation of horz line (in deg +/-90)
% returns NullOrient (image) and LineInd/CircInd which index the pixels for each element
%
% [NullOrient,LineInd,CircInd]=MakeNullOrient(150,55,11,3,18); imshow(NullOrient); %matched surface area version
% [NullOrient,LineInd,CircInd]=MakeNullOrient(150,55,11,11,-5); imshow(NullOrient); %matched width version

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

NullOrient=CircInd+LineR; %add images/indices to make final image
NullOrient(NullOrient>1)=1;

LineInd = logical(NullOrient-CircInd); %convert to 0s & 1s