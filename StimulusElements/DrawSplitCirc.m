function circIm=DrawSplitCirc(patchsize,circRad,gapwidth,rotate)
%circIm = DrawSplitCirc(patchsize,circRad,gapwidth,rotate)
%function to draw two half-circles separated by a gap, centred within a patch
%patchsize = patch dimensions, circRad = radius of circle halves, gapwidth =
%separation, rotate = 0-360 where 0 is horizontal gap line
%e.g. circIm = DrawSplitCirc(200,80,20,0); imshow(circIm)
%J Greenwood 2014

halfpx = round(patchsize/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy = round(patchsize/2)-0.5;

[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates
th(th<0)=th(th<0)+(2*pi);%th(th<180)=wrapTo2pi(th); %wrap to 0-360

absX = abs(meshpx); 
absY = abs(meshpy);

circIm = meshpx.*0; %create blank array for one sector
circIm(r<circRad+(0.5*gapwidth) & absY>(0.5*gapwidth))=1; %draw 1s within sector boundaries

circIm = round(imrotate(circIm,rotate,'bilinear','crop'));
