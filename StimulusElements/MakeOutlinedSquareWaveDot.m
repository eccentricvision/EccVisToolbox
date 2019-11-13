function [imFinal,gratInd,outInd,dotInd] = MakeOutlinedSquareWaveDot(patchsize,gratRad,theta,lambda,phase,numharmonics,con,lineWid,dotRad,dotOffset,cols,circsquare)
% [imFinal,gratInd,outInd,dotInd] = MakeOutlinedSquareWaveDot(patchsize,gratRad,theta,lambda,phase,numharmonics,con,lineWid,dotRad,dotOffset,cols,circsquare)
% function for making a square wave in a circular/square aperture with a coloured outline surrounding it (for IrrelSpaceCrowdExpt)

% patchsize = x/y patch size; gratRad = grating radius; theta = orientation of grating; lambda = spatial period in pixels (of fundamental sinewave);
% numharmonics = number of harmonic frequencies to be used; phase=phase!; con=contrast, lineWid1&2 = width of outlines, cols = grating/lines colours eg. [0 0 1; 0.5 0.5 0.5]
% circsquare = circle or square aperture/outline 1=circle, 2=square
% 
% eg  [imFinal,gratInd,outInd,dotInd] = MakeOutlinedSquareWaveDot(256,80, pi/2, 160, deg2rad(0),5,1,10,20,40,[0.8 0 0; 0 0.8 0; 0.8 0.8 0.8],1); ishow(imFinal);
% eg2 [imFinal,gratInd,outInd,dotInd] = MakeOutlinedSquareWaveDot(256,80, deg2rad(80), 200, 0,5,1,10,20,85,[0.8 0.8 0.8; 0 0.8 0; 0.8 0 0],2); ishow(imFinal);
% eg3 [imFinal,gratInd,outInd,dotInd] = MakeOutlinedSquareWaveDot(256,66,deg2rad(80), 66, pi/2,5,1,14,30,73,[0.8 0.8 0.8; 0.8 0 0; 0.8 0.8 0.8],1); ishow(imFinal); % -balanced feature sizes version
% J Greenwood 2013

if ~exist('circsquare')
    circsquare = 1;
end

%make the square wave
gratingBW = MakeSquareGrating(patchsize,patchsize, theta, lambda, phase,numharmonics,con); 
gratingBW = gratingBW>0; %round it to get rid of any banding

%make the aperture
if circsquare==1 %circle
    aperIm = DrawCirc(gratRad,[0 360],patchsize,patchsize);
    aperIm = logical(aperIm);
else %square
    aperIm = DrawRect(gratRad*2,gratRad*2,patchsize,patchsize); %DrawRect(x,y,px,py)
    aperIm = logical(aperIm);
end

%add the colour to make the patch

gratInd = logical(gratingBW.*aperIm); %indices for these pixels

%make the outline
if circsquare==1 %circles
outBW   = DrawCircOutline(gratRad+lineWid,lineWid,[0 360],patchsize,patchsize,[0 0]);
else
    outBW  = DrawRectOutline(patchsize,patchsize,(gratRad*2)+(2*lineWid),(gratRad*2)+(2*lineWid),lineWid,[0 360],[0 0]); %DrawRectOutline(PatchX,PatchY,rdiamX,rdiamY,LineWid,angRange,offset)
end
outBW  = logical(outBW);
outInd = logical(outBW);

%make the dot(s)
halfpx          = round(patchsize/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy          = round(patchsize/2)-0.5;
[meshpx,meshpy] = meshgrid(-halfpx+dotOffset:halfpx+dotOffset,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates
th(th<0)=th(th<0)+(2*pi);%th(th<180)=wrapTo2pi(th); %wrap to 0-360

dotBW = meshpx.*0; %create blank array
dotBW(r<dotRad)=1; %draw 1s within rectangle boundaries
dotBW = dotBW + fliplr(dotBW); %make two dots if necessary
dotBW(dotBW>1) = 1; %make sure any addition doesn't affect things
dotInd = logical(dotBW);

for cc=1:3
    dotIm(:,:,cc)  = dotBW.*cols(2,cc);
        outIm(:,:,cc) = outBW.*cols(3,cc);
end

%add it all together
for cc=1:3
    tempIm = zeros(patchsize,patchsize);
    tempIm(gratInd) = cols(1,cc);
    tempIm(outInd)  = cols(3,cc);
    tempIm(dotInd)  = cols(2,cc);
    imFinal(:,:,cc) = tempIm;
end
%imFinal   = gratingIm+dotIm+outIm;