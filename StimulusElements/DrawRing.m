function ringIm=DrawRing(rad1,rad2,angRange,px,py,con)
%function to draw a ring or ring segment centred within a patch
%rad1 = outer radius; rad2=inner radius angRange = [min max]; px/py = patch dimensions; con=contrast
%e.g. ringIm = DrawRing(100,80,[25 335],240,320,0.75); imshow(ringIm)
%e.g. ringIm = DrawRing(100,60,[0 360],250,250,0.95); imshow(ringIm)
%J Greenwood 2010

minAng=deg2rad(min(angRange)); %angles to plot
maxAng=deg2rad(max(angRange));
halfpx = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy = round(py/2)-0.5;

[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates
th(th<0)=th(th<0)+(2*pi);%th(th<180)=wrapTo2pi(th); %wrap to 0-360

circIm1 = meshpx.*0; %create blank array for outer circle
circIm1(r<rad1 & (th>minAng & th<maxAng))=1; %draw 1s within rectangle boundaries for outer circle

circIm2 = meshpx.*0; %blank array for inner circle
circIm2(r<rad2 & (th>minAng & th<maxAng))=1; %draw 1s within rectangle boundaries for inner circle

ringIm = (circIm1-circIm2).*con;