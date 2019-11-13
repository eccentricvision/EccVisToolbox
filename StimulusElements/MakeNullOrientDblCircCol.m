function [NullOrient,LineInd,CircInInd,CircOutInd]=MakeNullOrientDblCircCol(PatchSize,LineLen,LineWid,CircWidIn,CircWidOut,ori,cols)
%function [NullOrient,LineInd,CircInInd,CircOutInd]=MakeNullOrientDblCircCol(PatchSize,LineLen,LineWid,CircWidIn,CircWidOut,ori,cols)
% makes a 'no smoking' type null sign with two circles - can judge orientation of line and alter circle colours
%
% J Greenwood 2013
%
% PatchSize = total, LineLen = length of lines, LineWid = width of lines,
% CircWid = width of circle outline, TeeOr1/2 = relative orientation of horz/vert lines (in deg +/-90)
% cols = 4x3 array of RGB values for line,inner-circle,outer-circle,background
% returns NullOrient (image) and LineInd,CircInd,DotInd which index the pixels for each element
%
% [NullOrient,LineInd,CircInInd,CircOutInd]=MakeNullOrientDblCircCol(155,55,11,4,3,18,[1 0 0; 0 0.4 0; 1 0 0; 0.5 0.5 0.5]); imshow(NullOrient); %matched surface area version
% [NullOrient,LineInd,CircInInd,CircOutInd]=MakeNullOrientDblCircCol(155,55,11,11,11,-5,[0 0 0; 1 0 0; 0 0 0; 1 1 1]); imshow(NullOrient); %matched width version

InCircRad1  = LineLen/2; %inner radius of circle = teesize
OutCircRad1 = (LineLen/2)+CircWidIn; %inner radius of outer circle
OutCircRad2 = (LineLen/2)+CircWidIn+CircWidOut; %outer radius of outer circle

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

%make circles - need 3 to subtract and make inner/outer circs
Circ1 = meshX.*0; %create blank array
Circ1(meshR<OutCircRad2)=1; %draw 1s within rectangle boundaries
Circ2 = meshX.*0; %create blank array
Circ2(meshR<OutCircRad1)=1; %draw 1s within rectangle boundaries
Circ3 = meshX.*0; %create blank array
Circ3(meshR<InCircRad1)=1; %draw 1s within rectangle boundaries

CircOutInd = logical(Circ1-Circ2);
CircInInd  = logical(Circ2-Circ3);

NullOrient=zeros(PatchSize,PatchSize,3);
for cc=1:3 %make final colour image
    temp = (0.*meshX)+cols(4,cc); %background colour
    temp(LineInd) = cols(1,cc); %vert element
    temp(CircInInd) = cols(2,cc); %inner circle
    temp(CircOutInd)  = cols(3,cc); %outer circle
    NullOrient(:,:,cc) = temp;
end
