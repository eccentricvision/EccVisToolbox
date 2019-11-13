function RLineIm = DrawGaussianBlurRect(xsize,ysize,rectlen,rectwid,rtheta,sigmaX,sigmaY,gtheta,xoff,yoff)
% function RLineIm = DrawGaussianBlurRect(xsize,ysize,rectlen,rectwid,rtheta,sigmaX,sigmaY,gtheta)
% Draws a 3-parameter rectangle convolved with a 3-parameter 2D Gaussian, plus two parameters for stim size and two for the rectangle offset
% parameters: xsize/ysize (patchsize), rectlen (rect length), rectwid (rectangle width), rtheta (rect orientation in deg), 
% sigmaX/sigmaY (variance of Gaussian), gtheta (gaussian orientation in deg), xoff/yoff (offset of rectangle from centre where +ve = right or downward shift)
% NB. to work out SD from full width of Gaussian = FW/(2*sqrt(2*log(2)))
%
% eg.  RLineIm = DrawGaussianBlurRect(256,256,100,20,0,3,3,pi/2,0,0); imshow(RLineIm)
% eg2. RLineIm = DrawGaussianBlurRect(256,256,400,20,45,3,3,pi/2,0,0); imshow(RLineIm)
% eg3. RLineIm = DrawGaussianBlurRect(256,256,800,20,45,3,3,pi/2,0,100); imshow(RLineIm)
%
% J Greenwood Sept 2014, modified Mar 2017

GaussPatch = max([sigmaX sigmaY])*4; %size of the gaussian patch to be made (also used to pad the rectangle image)

%first make the meshgrid and rotate if required
[X,Y]  = meshgrid(-(xsize/2)-GaussPatch:(xsize/2)+GaussPatch-1,-(ysize/2)-GaussPatch:(ysize/2)+GaussPatch-1);
if rtheta>0 %rotate rectangle (if required)
    [TH,R] = cart2pol(X,Y);
    [X,Y]  = pol2cart(TH+deg2rad(rtheta),R);
end
X  = X-xoff;
Y  = Y-yoff;

% make the gaussian
gtheta = deg2rad(gtheta);
c1=cos(pi-gtheta);
s1=sin(pi-gtheta);
sigX_squared=2*sigmaX*sigmaX;
sigY_squared=2*sigmaY*sigmaY;

[X2,Y2] = meshgrid(-GaussPatch:GaussPatch,-GaussPatch:GaussPatch);
Xt      = X2.*c1 + Y2.*s1;
Yt      = Y2.*c1 - X2.*s1;
GaussIm = exp(-(Xt.*Xt)/sigX_squared-(Yt.*Yt)/sigY_squared);
GaussIm = GaussIm./max(GaussIm(:)); %normalise to 0-1

%next draw the rectangle element
RectLen   = (rectlen/2); %line width is always 1 (essentially set by gaussian SD) 
RectWid   = (rectwid/2);
RectIm      = zeros(ysize+2*GaussPatch,xsize+2*GaussPatch);
RectIm(X>=-RectLen & X<=RectLen & Y>=-RectWid & Y<=RectWid) = 1;%Line(X>-HalfLen & X<HalfLen & Y>-HalfWid & Y<HalfWid) = 1;
RectIm = RectIm./max(RectIm(:)); %normalise to 0-1

%now convolve the two
RLineIm = conv2(RectIm,GaussIm,'same');
RLineIm = RLineIm(1+GaussPatch:end-GaussPatch,1+GaussPatch:end-GaussPatch); %crop back down to expected size to avoid edge artefacts
RLineIm = RLineIm./max(RLineIm(:)); %normalise to 0-1