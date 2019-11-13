function [clockIm,WedgeInd,DotInd,CircInd]=DrawClockWedge(px,py,wedgerad,dotrad,circwid,orient,con)
% [clockIm,WedgeInd,DotInd,CircInd]=DrawClockWedge(px,py,wedgerad,dotrad,circwid,orient,con)
% function to draw a clock-type stimulus with a wedge of a quarter width centred within a patch
% px/py = patch dimensions, wedgerad = radius length of the wedge (total rad = linelen+circwid); dotrad=inner dot radius, circwid= circle width;
% orient = where the wedge is (0=right,90=up,etc) con = contrast(0-1)
% e.g. [clockIm,WedgeInd,DotInd,CircInd] = DrawClockWedge(400,400,120,30,20,0,1); imshow(clockIm)
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

clockIm = clockIm.*con;