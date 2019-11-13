function circIm=DrawCirc(rad,angRange,px,py)
%function to draw a circle or arc segment centred within a patch
%rad = radius; angRange = [min max]; px/py = patch dimensions
%e.g. circIm = DrawCirc(100,[25 335],240,320); imshow(circIm)
%eg2. circIm = DrawCirc(100,[0 180],300,300); imshow(circIm);
%J Greenwood 2010 - modified 2015 with modulus to keep image dimensions the same for odd/even pixel numbers

minAng=deg2rad(min(angRange)); %angles to plot
maxAng=deg2rad(max(angRange));
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

[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates
th(th<0)=th(th<0)+(2*pi);%th(th<180)=wrapTo2pi(th); %wrap to 0-360

circIm = meshpx.*0; %create blank array
circIm(r<rad & (th>=minAng & th<=maxAng))=1; %draw 1s within rectangle boundaries
