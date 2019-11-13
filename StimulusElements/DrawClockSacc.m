function clockIm=DrawClockSacc(px,py,outrad,dotrad,indotrad,circwid,linewid,orient,circcon,linecon,dotcon,indotcon,bgcon)
% clockIm=DrawClockSacc(px,py,outrad,dotrad,circwid,linewid,orient,con,dotcol,linecol,circcol,bgcol)
% function to draw a clock-type stimulus centred within a patch - as used in Crowded Saccades task
% px/py = patch dimensions, outrad = total radius; dotrad=central dot radius,indotrad = inner central dot radius, circwid= circle width; linewid=stroke width;
% orient = where the stroke is (0=right,90=up,etc), circcon,linecon,dotcon,indotcon,bgcon = contrast of each element (0-1)
% eg  clockIm = DrawClockSacc(300,300,125,30,15,15,30,90,0,0,0,1,0.5); imshow(clockIm)
% eg2 clockIm = DrawClockSacc(45,45,20,6,3,3,6,90,0,0,0,1,0.5); imshow(clockIm)
% J Greenwood 2011

halfpx = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired (and centre stimulus in middle with even pixels)
halfpy = round(py/2)-0.5;

[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates

inrad = outrad-(circwid); %radius of inner circle to make ring
tempIm = (meshpx.*0)+bgcon; %create blank array with background colour
%tempIm(r<outrad) = 1; %face colour of clock
tempIm(meshpx>0 & meshpx<inrad & meshpy<(0.5*linewid) & meshpy>-(0.5*linewid)) = linecon; %draw stroke of clock
tempIm(r<dotrad)=dotcon; %draw central dot
tempIm(r<indotrad)=indotcon;
tempIm(r<=outrad & r>=inrad)=circcon; %draw 1s within rectangle boundaries for outer circle
clockIm = tempIm;

if orient>0
    clockIm = imrotate(clockIm,orient,'crop'); %rotate if required
end