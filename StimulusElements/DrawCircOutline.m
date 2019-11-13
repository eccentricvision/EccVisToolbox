function circOutIm=DrawCircOutline(TotRad,LineWid,angRange,px,py,offset)
%function to draw a circle or arc segment OUTLINE centred within a patch
%Totrad = total radius; LineWid=linewidth angRange = [min max]; px/py = patch dimensions, offset = [x y] shift from centre
%e.g.  circOutIm = DrawCircOutline(100,10,[0 180],240,320, [0 0]); imshow(circOutIm)
%e.g.2 circOutIm = DrawCircOutline(100,10,[90 270],200,200, [-50 0]); imshow(circOutIm)
%J Greenwood 2013

if ~exist('offset','var')
    offset = [0 0]; %x/y offset
end

minAng=deg2rad(min(angRange)); %angles to plot
maxAng=deg2rad(max(angRange));
halfpx = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy = round(py/2)-0.5;

[meshpx,meshpy] = meshgrid(-halfpx+offset(1):halfpx+offset(1),-halfpy+offset(2):halfpy+offset(2)); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates
th(th<0)=th(th<0)+(2*pi);%th(th<180)=wrapTo2pi(th); %wrap to 0-360

InRad = TotRad-LineWid; %inner radius edge

circOutIm = meshpx.*0; %create blank array
circOutIm(r<TotRad & r>InRad & (th>minAng & th<maxAng))=1; %draw 1s within rectangle boundaries
