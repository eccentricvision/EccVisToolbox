function [circIm,circInd]=DrawBullseye(rad,numcirc,px,py)
% function to draw a bullseye (alternating black/white circles) centred within a patch
% rad = radius; numcirc = how many black/white alternations where 1=plain black circle; px/py = patch dimensions
% returns circIm (the image) and circInd (the indices where 1=bullseye present and 0 = background) to use for PTB transparency
%
% e.g. [circIm,circInd] = DrawBullseye(100,4,300,300); imshow(circIm)
% eg2. [circIm,circInd] = DrawBullseye(100,8,300,300); imshow(circIm);
%
% J Greenwood 2019 - modified from DrawCirc.m

minAng=deg2rad(0); %angles to plot
maxAng=deg2rad(360);
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

circrad = linspace(rad,round(rad/numcirc),numcirc); %radii for each circle in the bullseye (going outside in)
if numcirc>1
    circcon = (repmat([0 1],[1 ceil(numcirc/2)])); %alternating contrast values
    circcon = fliplr(circcon(1:numcirc)); %select correct number of contrast values and make sure inner dot always black
else
    circcon = 0;
end
for cc=1:numcirc
    circIm(r<circrad(cc) & (th>=minAng & th<=maxAng))=circcon(cc); %draw 1s within rectangle boundaries
end
circInd = meshpx.*0; %blank array for indices
circInd(r<rad & (th>=minAng & th<=maxAng))=1;