% MakeCosineRing
%
% res=MakeCosineRing(m,rad,band)
% Makes an image containing a cosinusoidally windowed disk.
% m is image dimension, rad is disk radius, band is the
% width of the band around the disk edge to be cosinusoidally 
% modulated. Result is a 0-1 scaled (double) matrix.
%
% e.g. imagesc(MakeCosineWindow(256,100,20)); axis square; colormap(gray(256))
% shows a 256X256 image containing a disk of radius 100 pixels
% with an outer band, extending from 90-110 pixels from the centre,
% that is consinusoidally modulated from 1 to 0.
%
% john greenwood and sam solomon 2014, modified from some Dakin code
%
function resFinal=MakeCosineRing(m,inrad,outrad,band,x1,y1)
if ~exist('x1')
    x1=0;
end
if ~exist('y1')
    y1=0;
end

if length(m) == 1
    m(2) = m;
end

[X,Y] = meshgrid(-m(2)/2:m(2)/2-1,-m(1)/2:m(1)/2-1);

X=X-x1;
Y=Y-y1;
%make the outer radius
dist=abs(X+Y.*i);
res1=0.5+(outrad-dist)./band;
res1(dist<(outrad-band/2))=1;
res1(dist>=(outrad+band/2))=0;
res1=0.5+0.5.*(-cos(res1.*pi));

%make the inner radius
dist=abs(X+Y.*i);
res2=0.5+(inrad-dist)./band;
res2(dist<(inrad-band/2))=1;
res2(dist>=(inrad+band/2))=0;
res2 = 1-res2;
res2=0.5+0.5.*(-cos(res2.*pi));

resFinal = res1.*res2;

