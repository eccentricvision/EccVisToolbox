function [clockIm,LineInd,DotInd,CircInd]=DrawClockV2(px,py,linelen,dotrad,circwid,linewid,orient,con)
% [clockIm,LineInd,DotInd,CircInd]=DrawClockV2(px,py,linelen,dotrad,circwid,linewid,orient,con)
% function to draw a clock-type stimulus centred within a patch
% px/py = patch dimensions, linelen = line length (total rad = linelen+circwid); dotrad=inner dot radius, circwid= circle width; linewid=stroke width;
% orient = where the stroke is (0=right,90=up,etc) con = contrast(0-1)
% e.g. [clockIm,LineInd,DotInd,CircInd] = DrawClockV2(400,400,120,30,20,20,0,1); imshow(clockIm)
%
% J Greenwood 2011

halfpx = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired (and centre stimulus in middle with even pixels)
halfpy = round(py/2)-0.5;

[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates

inrad  = linelen;
outrad = linelen+circwid;
clockIm = meshpx.*0; %create blank array
clockIm(r<=outrad & r>=inrad)=1; %draw 1s within rectangle boundaries for outer circle
CircInd = logical(clockIm); %just the outer circle coordinates
clockIm(r<dotrad)=1; %draw inner dot
DotInd = logical(clockIm - CircInd); %just the inner dot coordinates
clockIm(meshpx>0 & meshpx<inrad & meshpy<(0.5*linewid) & meshpy>-(0.5*linewid)) = 1; %draw stroke of clock

if orient>0
    clockIm = imrotate(clockIm,orient,'crop'); %rotate if required
end
LineInd = logical(clockIm - DotInd - CircInd); %just the line coordinates (properly shaped and all) - NB Take this after rotation!!!

clockIm = clockIm.*con;