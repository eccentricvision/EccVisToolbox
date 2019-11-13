function [imFinal,gratInd,inInd,outInd] = MakeDblOutlinedSquareWave(patchsize,gratRad,theta,lambda,phase,numharmonics,con,lineWidIn,lineWidOut,cols,circsquare)
% imFinal = MakeOutlinedSquareWave(patchsize,gratRad,theta,lambda,phase,numharmonics,con,lineWid,cols,circsquare)
% function for making a square wave in a circular/square aperture with a coloured outline surrounding it (for IrrelSpaceCrowdExpt)

% patchsize = x/y patch size; gratRad = grating radius; theta = orientation of grating; lambda = spatial period in pixels (of fundamental sinewave);
% numharmonics = number of harmonic frequencies to be used; phase=phase!; con=contrast, lineWid1&2 = width of outlines, cols = grating/lines colours eg. [0 0 1; 0.5 0.5 0.5]
% circsquare = circle or square aperture/outline 1=circle, 2=square
% 
% eg  [imFinal,gratInd,inInd,outInd] = MakeDblOutlinedSquareWave(256,80, pi/2, 160, deg2rad(0),5,1,10,10,[0.8 0 0; 0 0.8 0; 0.8 0.8 0.8],1); ishow(imFinal);
% eg2 [imFinal,gratInd,inInd,outInd] = MakeDblOutlinedSquareWave(256,80, deg2rad(80), 200, 0,5,1,10,10,[0.8 0.8 0.8; 0 0.8 0; 0.8 0 0],2); ishow(imFinal);
% eg3 [imFinal,gratInd,inInd,outInd] = MakeDblOutlinedSquareWave(256,66,deg2rad(80), 66*2, 0,5,1,14,12,[0.8 0.8 0.8; 0.8 0.8 0.8; 0.8 0 0],1); ishow(imFinal); % -balanced feature sizes version
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
for cc=1:3
    gratingIm(:,:,cc) = gratingBW.*aperIm.*cols(1,cc);
end
gratInd = logical(gratingBW.*aperIm); %indices for these pixels

%make the outlines
if circsquare==1 %circles
outBW  = DrawCircOutline(gratRad+lineWidIn+lineWidOut,lineWidOut,[0 360],patchsize,patchsize,[0 0]);
inBW   = DrawCircOutline(gratRad+lineWidIn,lineWidIn,[0 360],patchsize,patchsize,[0 0]);
else
    outBW = DrawRectOutline(patchsize,patchsize,(gratRad*2)+(2*lineWidIn)+(2*lineWidOut),(gratRad*2)+(2*lineWidIn)+(2*lineWidOut),lineWidOut,[0 360],[0 0]); %DrawRectOutline(PatchX,PatchY,rdiamX,rdiamY,LineWid,angRange,offset)
    inBW  = DrawRectOutline(patchsize,patchsize,(gratRad*2)+(2*lineWidIn),(gratRad*2)+(2*lineWidIn),lineWidIn,[0 360],[0 0]); %DrawRectOutline(PatchX,PatchY,rdiamX,rdiamY,LineWid,angRange,offset)
end
outBW  = logical(outBW);
inBW   = logical(inBW);
for cc=1:3
    inIm(:,:,cc)  = inBW.*cols(2,cc);
        outIm(:,:,cc) = outBW.*cols(3,cc);
end
inInd  = logical(inBW);
outInd = logical(outBW);

%add it all together
imFinal   = gratingIm+inIm+outIm;