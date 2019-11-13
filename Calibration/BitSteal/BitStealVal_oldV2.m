function [imValVolt]=BitStealVal(imValLum,LR,vLUT)
% bitstealing code for luminance values (0-1), returning an RGB array as imValVolt
% need to already have loaded load('C:\Users\JohnG\Matlab Files\Calibration\BitStealCal3D.mat');
% or similar and have a LR structure
% and run InitialiseBitSteal to generate vLUT
% J Greenwood 2014 
% modified from code by Steven Dakin (now just a simple look up table based
% on number of possible luminance values - quicker to compute whole image)

displayableL=LR.VtoLfunR(LR,vLUT(:,1)')+LR.VtoLfunG(LR,vLUT(:,2)')+LR.VtoLfunB(LR,vLUT(:,3)');
numLum   = numel(displayableL);
% imValLum = imValLum.*max(displayableL); %convert to displayable luminance range
% ImSize = size(imValLum);
% uniqueVals = unique(imValLum); %how many contrast values requested

imValLUT = round((imValLum.*(numLum-1))+1); %e.g. if 1786 luminance values then round to numbers from 1-1786 where 0 con is 1 and 1786 is 1

up to here need to make a lookup table of 1786 possible luminance values (as currently doesn't gamma correct) and then put this into imValVolt
imValLum = (imValLum.*max(displayableL));
for col=1:3
    colLUT = vLUT(:,col);
    imValVolt(:,:,col) = colLUT(imValLUT); %gets the relevant colour gun voltage for a desired luminance value
end

if numel(imValLum)==1 %ie if just want a single value
    imValVolt=squeeze(imValVolt)'; %reduce to 1x3 number array (as old output expected)
end