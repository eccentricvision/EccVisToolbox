function flapIm=DrawCircFlap(CircRad,RectLen,px,py)
% flapIm=DrawCircFlap(CircRad,RectLen,px,py)
% function to draw a rectangular segment with semi-circles asymmetrically added, within a patch
% Totrad = total radius of circles; RectLen=length of rectangle inner segment 
% px/py = patch dimensions
% also related to DrawCircCutRect.m which makes just the rectangle with the cutout semicircle
%
% J Greenwood 2013
%
% e.g. flapIm = DrawCircFlap(40,140,400,400); imshow(flapIm)

%first draw rectangle (slightly longer to keep symmetry when semicircles added)
halfx   = round(RectLen/2);
halfy   = CircRad;
halfpx  = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy  = round(py/2)-0.5;
rectoff = round(CircRad/4);

[meshpx,meshpy] = meshgrid(-halfpx-rectoff:halfpx-rectoff,-halfpy:halfpy); %coordinates for rectangle
rectIm = meshpx.*0; %create blank array
rectIm(abs(meshpx)<halfx & abs(meshpy)<halfy)=1; %draw 1s within rectangle boundaries

%then cut out semicircle from right side
offset = round(RectLen/2); %centre of the semicircle cut-out
[meshpx,meshpy] = meshgrid(-halfpx-offset-rectoff:halfpx-offset-rectoff,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates
th(th<0)=th(th<0)+(2*pi);%th(th<180)=wrapTo2pi(th); %wrap to 0-360
RightSemi = meshpx.*0; %create blank array
RightSemi(r<CircRad & (th>pi/2 & th<1.5*pi))=1; %draw 1s within semi-circle boundaries
flapIm = rectIm-RightSemi; %subtract cutout

%then add semicircle to left side
meshpx=fliplr(meshpx);
[meshpx,meshpy] = meshgrid(-halfpx+offset-rectoff:halfpx+offset-rectoff,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates
th(th<0)=th(th<0)+(2*pi);%th(th<180)=wrapTo2pi(th); %wrap to 0-360
LeftSemi = meshpx.*0; %create blank array
LeftSemi(r<CircRad & (th>0 & th<2*pi))=1; %draw 1s within semi-circle boundaries
LeftSemi = LeftSemi-rectIm;
LeftSemi(LeftSemi<0)=0; %round image
flapIm = flapIm+LeftSemi; %subtract cutout
flapIm(flapIm>1)=1; %round final image
