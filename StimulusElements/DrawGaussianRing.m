function GRingIm = DrawGaussianRing(xsize,ysize,totrad,linewid,sigmaX,sigmaY,gtheta)
% function GLineIm = DrawGaussianRing(xsize,ysize,linelen,linetheta,sigmaX,sigmaY,gtheta)
% Draws a 2-parameter line convolved with a 3-parameter 2D Gaussian
% parameters: xsize/ysize (patchsize), linelen (line length), linetheta (line orientation), 
% sigmaX/sigmaY (variance of Gaussian), gtheta (gaussian orientation)
% xoff/yoff are x/y offsets from centre
% Note linetheta is in degrees and gtheta in radians (confusing? whatever)
% NB. to work out SD from full width of Gaussian = FW/(2*sqrt(2*log(2)))
%
% eg.  GLineIm = DrawGaussianRing(400,400,128,1,3,3,pi/2); imshow(GLineIm)
% eg2. GLineIm = DrawGaussianRing(256,256,128,1,3,3,pi/2,20,40); imshow(GLineIm)
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

%next draw the ring element
halfpx = round(xsize/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy = round(ysize/2)-0.5;

[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates
th(th<0)=th(th<0)+(2*pi);%th(th<180)=wrapTo2pi(th); %wrap to 0-360

InRad = totrad-linewid; %inner radius edge

circOutIm = meshpx.*0; %create blank array
circOutIm(r<totrad & r>InRad)=1; %draw 1s within rectangle boundaries

%now convolve the two
GRingIm = conv2(circOutIm,GaussIm,'same');
GRingIm = GRingIm./max(GRingIm(:)); %normalise to 0-1

