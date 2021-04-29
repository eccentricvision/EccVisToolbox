function res=MakeCosineEllipse(m,MajorRad,MinorRad,band,x1,y1,orient)
% MakeCosineWindow
%
% res=MakeCosineEllipse(m,MajorRad,MinorRad,band,x1,y1,orient)
% Makes an image containing a cosinusoidally windowed ellipse.
% m is image dimension, MajorRad is the large radius and MinorRad the smaller one (MinorRad cannot exceed MajorRad),
% band is the width of the band around the disk edge to be cosinusoidally 
% modulated, and orient is the orientation in deg (0=horz, 90=vert). 
% Result is a 0-1 scaled (double) matrix.
% NB first value m can be input as a matrix [m n] if rectangular image is desired
%
% code by steven dakin (s.dakin@ucl.ac.uk), modified J Greenwood April 2021
%
% e.g. im = MakeCosineEllipse(400,100,50,20,0,0,0); imshow(im);
% or   im = MakeCosineEllipse(400,120,50,20,0,0,90); imshow(im);

if ~exist('x1')
    x1=0;
end
if ~exist('y1')
    y1=0;
end

if length(m) == 1
    m(2) = m;
end

AspRatio = MajorRad./MinorRad; %work out aspect ratio of the ellipse
%m(2)     = m(2).*(AspRatio); %apply aspect ratio to x-axis
[X,Y] = meshgrid(-m(2)/2:m(2)/2-1,-((m(1)*AspRatio/2)):AspRatio:(((m(1)*AspRatio)/2))-1);
%[X,Y] = meshgrid(-m(2)/2:m(2)/2-1,-m(1)/2:m(1)/2-1);

X=X-x1;
Y=Y-y1;
dist=abs(X+Y.*i);
res=0.5+(MajorRad-dist)./band;
res(dist<(MajorRad-band/2))=1;
res(dist>=(MajorRad+band/2))=0;
res=0.5+0.5.*(-cos(res.*pi));
%res=imresize(res,[m(2) m(1)]); %shrink image down to desired size

if orient>0
   res=imrotate(res,orient); 
end
