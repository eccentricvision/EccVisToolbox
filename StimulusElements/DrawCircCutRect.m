function flapIm=DrawCircCutRect(CircRad,RectLen,px,py)
% flapIm=DrawCircCutRect(CircRad,RectLen,px,py)
% function to draw a rectangular segment with one semi-circles cutout from the RHS
% Totrad = total radius of circles; RectLen=length of rectangle inner segment 
% px/py = patch dimensions
% also related to DrawCircFlap.m which makes the rectangle with both the cutout semicircle and another added to the other side
%
% J Greenwood 2013
%
% e.g. flapIm = DrawCircCutRect(40,140,400,400); imshow(flapIm)

%first draw rectangle (slightly longer to keep symmetry when semicircles added)
halfx   = round(RectLen/2);
halfy   = CircRad;
halfpx  = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy  = round(py/2)-0.5;

[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
rectIm = meshpx.*0; %create blank array
rectIm(abs(meshpx)<halfx & abs(meshpy)<halfy)=1; %draw 1s within rectangle boundaries

%then cut out semicircle from right side
offset = round(RectLen/2); %centre of the semicircle cut-out
[meshpx,meshpy] = meshgrid(-halfpx-offset:halfpx-offset,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates
th(th<0)=th(th<0)+(2*pi);%th(th<180)=wrapTo2pi(th); %wrap to 0-360
RightSemi = meshpx.*0; %create blank array
RightSemi(r<CircRad & (th>pi/2 & th<1.5*pi))=1; %draw 1s within semi-circle boundaries
flapIm = rectIm-RightSemi; %subtract cutout
flapIm(flapIm>1)=1; %round final image
