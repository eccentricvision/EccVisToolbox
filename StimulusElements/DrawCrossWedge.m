function [clockIm,WedgeInd,CrossInd,CircInd]=DrawCrossWedge(px,py,wedgerad,crosswid,circwid,orient,con)
% [clockIm,WedgeInd,CrossInd,CircInd]=DrawCrossWedge(px,py,wedgerad,crosswid,circwid,orient,con)
% function to draw a clock-type stimulus with a cross and a wedge of a quarter width
% px/py = patch dimensions, wedgerad = radius length of the wedge (total rad = linelen+circwid); crosswid=width of cross lines, circwid= circle width;
% orient = where the wedge is (0=right,90=up,etc) con = contrast(0-1)
% e.g. [clockIm,WedgeInd,CrossInd,CircInd] = DrawCrossWedge(400,400,120,20,20,0,1); imshow(clockIm)
%
% J Greenwood 2011

halfpx  = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired (and centre stimulus in middle with even pixels)
halfpy  = round(py/2)-0.5;
linelen = wedgerad*2;

[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates

inrad  = wedgerad;
outrad = wedgerad+circwid;
clockIm = meshpx.*0; %create blank array

%outer circle
clockIm(r<=outrad & r>=inrad)=1; %draw 1s within rectangle boundaries for outer circle
CircInd = logical(clockIm); %just the outer circle coordinates

%make the cross
HalfLen   = (linelen/2)+1; %extend length a bit to avoid gaps with circle (not a visible increase otherwise)
HalfWid   = crosswid/2;
LineIm    = clockIm.*0;
LineIm(meshpx>-HalfLen & meshpx<HalfLen & meshpy>-HalfWid & meshpy<HalfWid) = 1;
%rotate lines
Cross1   = imrotate(LineIm,45,'crop'); %rotates each element
Cross2   = imrotate(LineIm,-45,'crop'); %rotates each element
clockIm  = logical(clockIm+Cross1+Cross2);
%clockIm(clockIm>1)=1; %round to 0-1
CrossInd = logical(clockIm-CircInd);

%draw the wedge
clockIm(r<=wedgerad & th>0 & th<(pi/4))=1; %draw wedge of clock (half)
clockIm(r<=wedgerad & th<0 & th>(-pi/4))=1; %draw wedge of clock (other half)
WedgeInd = logical(clockIm - CrossInd - CircInd); %just the line coordinates (properly shaped and all) - NB Take this after rotation!!!

if orient>0
    clockIm  = imrotate(clockIm,orient,'crop'); %rotate if required
    CrossInd = imrotate(CrossInd,orient,'crop'); %rotate cross indices too
    WedgeInd = imrotate(WedgeInd,orient,'crop'); %rotate Wedge indices too
end

clockIm = clockIm.*con;