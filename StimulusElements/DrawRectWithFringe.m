function RectIm = DrawRectWithFringe(xsize,ysize,rectlen,rectwid,fringe,rtheta,xoff,yoff)
% function RLineIm = DrawRectWithFringe(xsize,ysize,rectlen,rectwid,lenfringe,widfringe,rtheta,xoff,yoff)
% Draws a rectangle surrounded by a linear ramp in luminance
% parameters: xsize/ysize (patchsize), rectlen (rect length), rectwid
% (rectangle width), fringe (size of ramp in pixels), % rtheta (rect orientation in deg),  
% xoff/yoff (offset of rectangle from centre where +ve = right or downward shift)
%
% similar to DrawGaussianBlurRect
%
% J Greenwood Sept 2014, modified Mar 2017
%
% eg.  RectIm  = DrawRectWithFringe(256,256,100,20,3,0,0,0); imshow(RectIm)
% eg2. RectIm  = DrawRectWithFringe(512,256,1000,20,20,45,0,108); imshow(RectIm)

%first make the meshgrid and rotate if required

[X,Y]  = meshgrid(-(xsize/2):(xsize/2)-1,-(ysize/2):(ysize/2)-1);
if rtheta>0 %rotate rectangle (if required)
    [TH,R] = cart2pol(X,Y);
    [X,Y]  = pol2cart(TH+deg2rad(rtheta),R);
end
X  = X-xoff;
Y  = Y-yoff;

%fringe vals
FringeVals = linspace(1,0,fringe+2); %the fringe for length
FringeVals = FringeVals(1:end-1); %crop off 0 val (no use)

%make line
RectLen   = (rectlen/2); %line width is always 1 (essentially set by gaussian SD) 
RectWid   = (rectwid/2);
RectIm    = single(zeros(ysize,xsize));
%next draw the rectangle element - loop through fringe values to fill in edges
for f = numel(FringeVals):-1:1
    RectIm(X>=-RectLen-(f-1) & X<=RectLen+(f-1) & Y>=-RectWid-(f-1) & Y<=RectWid+(f-1)) = FringeVals(f);%Line(X>-HalfLen & X<HalfLen & Y>-HalfWid & Y<HalfWid) = 1;
end
RectIm = RectIm./max(RectIm(:)); %normalise to 0-1
