function RadGradient=DrawRadialGradient(slope,px,py);
%RadGradient=DrawRadialGradient(rad,slope,px,py);
%function to draw a radial gradient
%centre will be 0 and the outer edge will be the max of 'slope' parameter
%inputs are slope = slope of the gradient and px,py are image dimensions;
%
%e.g. RadGradient=DrawRadialGradient(3,300,300); imshow(RadGradient);

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

rNorm = r./max(r(:));
RadGradient = rNorm.*slope;