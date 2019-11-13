function [clockIm,WedgeInd,DotInd,CircInd]=DrawClockWedgeCol(px,py,wedgerad,dotrad,circwid,orient,cols)
% [clockIm,WedgeInd,DotInd,CircInd]=DrawClockWedgeCol(px,py,wedgerad,dotrad,circwid,orient,con)
% function to draw a COLOUR clock-type stimulus with a wedge of a quarter width centred within a patch
% px/py = patch dimensions, wedgerad = radius length of the wedge (total rad = linelen+circwid); dotrad=inner dot radius, circwid= circle width;
% orient = where the wedge is (0=right,90=up,etc), cols = 4x3 array of RGB values for wedge,circle,dot,background
% e.g. [clockIm,WedgeInd,DotInd,CircInd] = DrawClockWedgeCol(400,400,120,30,20,0,[1 0 0; 0 0.4 0; 0 0.4 0; 0.5 0.5 0.5]); imshow(clockIm)
%
% J Greenwood 2011

halfpx = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired (and centre stimulus in middle with even pixels)
halfpy = round(py/2)-0.5;

[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates

inrad  = wedgerad;
outrad = wedgerad+circwid;
clockIm = meshpx.*0; %create blank array

clockIm(r<=outrad & r>=inrad)=1; %draw 1s within rectangle boundaries for outer circle
CircInd = logical(clockIm); %just the outer circle coordinates

clockIm(r<dotrad)=1; %draw inner dot
DotInd = logical(clockIm - CircInd); %just the inner dot coordinates

clockIm(r<=wedgerad & th>0 & th<(pi/4))=1; %draw wedge of clock (half)
clockIm(r<=wedgerad & th<0 & th>(-pi/4))=1; %draw wedge of clock (other half)

if orient>0
    clockIm = imrotate(clockIm,orient,'crop'); %rotate if required
end
WedgeInd = logical(clockIm - DotInd - CircInd); %just the line coordinates (properly shaped and all) - NB Take this after rotation!!!

for cc=1:3 %make final colour image
    temp = (0.*meshpx)+cols(4,cc); %background colour
    temp(WedgeInd) = cols(1,cc); %wedge element
    temp(CircInd)  = cols(2,cc); %circle
    temp(DotInd)   = cols(3,cc); %dot
    clockIm(:,:,cc) = temp;
end
