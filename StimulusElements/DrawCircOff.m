function circOutIm=DrawCircOff(TotRad,angRange,px,py,offset)
%function to draw a circle or arc segment with an offset within a patch
%Totrad = total radius; LineWid=linewidth angRange = [min max]; px/py = patch dimensions, offset = [x y] shift from centre
%e.g.  circOutIm = DrawCircOff(100,[0 180],240,320, [0 0]); imshow(circOutIm)
%e.g.2 circOutIm = DrawCircOff(100,[90 270],200,200, [-50 0]); imshow(circOutIm)
%J Greenwood 2013, updated August 2021

if ~exist('offset','var')
    offset = [0 0]; %x/y offset
end

minAng=deg2rad(min(angRange)); %angles to plot
maxAng=deg2rad(max(angRange));
%halfpx = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired
%halfpy = round(py/2)-0.5;
if mod(px,2) %odd number
    halfpx = round(px/2)-1; %to keep number of pixels the same as desired
else %even number
    halfpx = (px/2)-0.5; %-0.5 to keep number of pixels the same as desired
end
if mod(py,2) %odd number
    halfpy = round(py/2)-1; %to keep number of pixels the same as desired
else %even number
    halfpy = (py/2)-0.5;
end

[meshpx,meshpy] = meshgrid(-halfpx+offset(1):halfpx+offset(1),-halfpy+offset(2):halfpy+offset(2)); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates
th(th<0)=th(th<0)+(2*pi);%th(th<180)=wrapTo2pi(th); %wrap to 0-360

circOutIm = meshpx.*0; %create blank array
circOutIm(r<TotRad & (th>minAng & th<maxAng))=1; %draw 1s within rectangle boundaries
