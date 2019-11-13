function [imFinal,gratInd,outInd] = MakeOutlinedSquareWaveBW(patchsize,gratRad,theta,lambda,phase,numharmonics,con,lineWid,circsquare)
% [imFinal,gratInd,outInd] = MakeOutlinedSquareWaveBW(patchsize,gratRad,theta,lambda,phase,numharmonics,con,lineWid,circsquare)
% function for making a square wave in a circular aperture with an outline surrounding it (for IrrelSpaceCrowdExpt)
% NB BLACK AND WHITE ONLY
% grating = MakeSquareGrating(m,n,theta,lambda,phase,con);
% patchsize = x/y patch size; gratRad = grating radius; theta = orientation of grating; lambda = spatial period in pixels (of fundamental sinewave);
% numharmonics = number of harmonic frequencies to be used; phase=phase!; con=contrast, lineWid = width of outline
% circsquare = circle or square aperture/outline 1=circle, 2=square

% e.g. [imFinal,gratInd,outInd] = MakeOutlinedSquareWaveBW(256,80, pi/2, 24, pi/2,5,1,10,1); ishow(imFinal);
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
gratingIm = gratingBW.*aperIm.*con;
gratInd = logical(gratingBW.*aperIm); %indices for these pixels

%make the outline
if circsquare==1 %circle
    outIm  = DrawCircOutline(gratRad+lineWid,lineWid,[0 360],patchsize,patchsize,[0 0]);
else
    outIm = DrawRectOutline(patchsize,patchsize,(gratRad*2)+(2*lineWid),(gratRad*2)+(2*lineWid),lineWid,[0 360],[0 0]); %DrawRectOutline(PatchX,PatchY,rdiamX,rdiamY,LineWid,angRange,offset)
end
outIm  = logical(outIm);
outInd = logical(outIm);

%add it all together
imFinal   = gratingIm+outIm;