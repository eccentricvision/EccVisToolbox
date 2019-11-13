function GLineIm = DrawGaussianLine(xsize,ysize,linelen,linetheta,sigmaX,sigmaY,gtheta,xoff,yoff)
% function GLineIm = DrawGaussianLine(xsize,ysize,linelen,linetheta,sigmaX,sigmaY,gtheta)
% Draws a 2-parameter line convolved with a 3-parameter 2D Gaussian
% parameters: xsize/ysize (patchsize), linelen (line length), linetheta (line orientation), 
% sigmaX/sigmaY (variance of Gaussian), gtheta (gaussian orientation)
% xoff/yoff are x/y offsets from centre
% Note linetheta is in degrees and gtheta in radians (confusing? whatever)
% NB. to work out SD from full width of Gaussian = FW/(2*sqrt(2*log(2)))
%
% eg.  GLineIm = DrawGaussianLine(256,256,128,0,3,3,pi/2,0,0); imshow(GLineIm)
% eg2. GLineIm = DrawGaussianLine(256,256,128,0,3,3,pi/2,20,40); imshow(GLineIm)
%
% J Greenwood Sept 2014

if mod(xsize,2)==0 %need an odd number for this
    xsize=xsize+1;
end
if mod(ysize,2)==0;
    ysize=ysize+1;
end

%meshgrid for all images
[X,Y]=meshgrid(-xsize/2:xsize/2-1,-ysize/2:ysize/2-1);

%first draw the Gaussian element
% speedy variables
c1=cos(pi-gtheta);
s1=sin(pi-gtheta);
sigX_squared=2*sigmaX*sigmaX;
sigY_squared=2*sigmaY*sigmaY;

% rotate co-ordinates
Xt = X.*c1 + Y.*s1;
Yt = Y.*c1 - X.*s1;

GaussIm = exp(-(Xt.*Xt)/sigX_squared-(Yt.*Yt)/sigY_squared);
GaussIm = GaussIm./max(GaussIm(:)); %normalise to 0-1

%next draw the line element
X  = X-xoff; %first offset the meshgrid
Y  = Y-yoff;

if linetheta==0 %horizontal line
    HalfLen   = (linelen/2); %line width is always 1 (essentially set by gaussian SD) HalfWid   = (1);
    LineIm      = zeros(ysize,xsize);
    LineIm(X>-HalfLen & X<HalfLen & Y<1 & Y>-1) = 1;%Line(X>-HalfLen & X<HalfLen & Y>-HalfWid & Y<HalfWid) = 1;
elseif linetheta==90 %vertical line
    HalfLen   = (linelen/2); %line width is always 1 (essentially set by gaussian SD) HalfWid   = (1);
    LineIm      = zeros(ysize,xsize);
    LineIm(Y>-HalfLen & Y<HalfLen & X<1 & X>-1) = 1;%Line(X>-HalfLen & X<HalfLen & Y>-HalfWid & Y<HalfWid) = 1;
else %take a horizontal line and rotate it
    HalfLen   = (linelen/2); %line width is always 1 (essentially set by gaussian SD) HalfWid   = (1);
    LineIm      = zeros(ysize,xsize);
    LineIm(X>-HalfLen & X<HalfLen & Y<1 & Y>-1) = 1;%Line(X>-HalfLen & X<HalfLen & Y>-HalfWid & Y<HalfWid) = 1;
    %rotate line
    if linetheta>0
        LineIm  = imrotate(LineIm,linetheta,'crop'); %rotates each element
    end
end
LineIm = LineIm./max(LineIm(:)); %normalise to 0-1

%now convolve the two
GLineIm = conv2(LineIm,GaussIm,'same');
GLineIm = GLineIm./max(GLineIm(:)); %normalise to 0-1