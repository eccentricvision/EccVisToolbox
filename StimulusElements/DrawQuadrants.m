function quadIm=DrawQuadrants(patchsize,circRad,gapwidth,rotate)
%quadIm = DrawQuadrants(patchsize,circRad,gapwidth,rotate)
%function to draw four quadrants separated by a gap, centred within a patch
%patchsize = patch dimensions, circRad = radius of quadrants, gapwidth =
%separation, rotate = 0-360 where 0 is cardinal gap lines
%e.g. quadIm = DrawQuadrants(200,80,20,45); imshow(quadIm)
%J Greenwood 2014

halfpx = round(patchsize/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy = round(patchsize/2)-0.5;

[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates
th(th<0)=th(th<0)+(2*pi);%th(th<180)=wrapTo2pi(th); %wrap to 0-360

absX = abs(meshpx); 
absY = abs(meshpy);

quadIm = meshpx.*0; %create blank array for one sector
quadIm(r<circRad+(0.5*gapwidth) & absX>(0.5*gapwidth) & absY>(0.5*gapwidth))=1; %draw 1s within sector boundaries

quadIm = round(imrotate(quadIm,rotate,'bilinear','crop'));
