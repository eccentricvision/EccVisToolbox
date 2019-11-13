function clockIm=DrawClockCol(px,py,outrad,dotrad,featwid,linewid,orient,con,dotcol,linecol,circcol,facecol,bgcol)
% clockIm=DrawClockCol(px,py,outrad,dotrad,featwid,linewid,orient,con,dotcol,linecol,circcol,bgcol)
% function to draw a COLOUR clock-type stimulus centred within a patch
% px/py = patch dimensions, outrad = total radius; dotrad=inner dot radius, featwid= circle/dot width; linewid=stroke width;
% orient = where the stroke is (0=right,90=up,etc) con = contrast(0-1), dotcol/linecol/circcol/facecol/bgcol = 3 element colour arrays
% e.g. clockIm = DrawClockCol(300,300,120,30,20,20,0,1,[1 0 0],[0 0 0],[0 0 0],[1 1 1],[0.5 0.5 0.5]); imshow(clockIm)
%
% J Greenwood 2011

halfpx = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired (and centre stimulus in middle with even pixels)
halfpy = round(py/2)-0.5;

[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates

inrad = outrad-(featwid); %radius of inner circle to make ring
for cc=1:3
    tempIm = (meshpx.*0)+bgcol(cc); %create blank array with background colour
    tempIm(r<outrad) = facecol(cc); %face colour of clock
    tempIm(meshpx>0 & meshpx<inrad & meshpy<(0.5*linewid) & meshpy>-(0.5*linewid)) = linecol(cc); %draw stroke of clock
    tempIm(r<dotrad)=dotcol(cc); %draw inner dot
    tempIm(r<=outrad & r>=inrad)=circcol(cc); %draw 1s within rectangle boundaries for outer circle
    clockIm(:,:,cc) = tempIm;
end

if orient>0
    clockIm = imrotate(clockIm,orient,'crop'); %rotate if required
end

clockIm = clockIm.*con;