function [imValVolt]=BitStealVal(imValLum,LR,vLUT)
% bitstealing code for luminance values (0-1), returning an RGB array as imValVolt
% need to already have loaded load('C:\Users\JohnG\Matlab Files\Calibration\BitStealCal3D.mat');
% or similar and have a LR structure
% and run InitialiseBitSteal to generate vLUT
% now uses lookup tables in LR (from Initialise code) to look up possible
% luminance values and apply these across the whole image
%
% J Greenwood 2014 (modified from code by Steven Dakin 2010)

displayableL=LR.VtoLfunR(LR,vLUT(:,1)')+LR.VtoLfunG(LR,vLUT(:,2)')+LR.VtoLfunB(LR,vLUT(:,3)');
numLum   = numel(displayableL);

imValLUT = round((imValLum.*(numLum-1))+1); %e.g. if 1786 luminance values then round to numbers from 1-1786 where 0 con is 1 and 1786 is 1

for col=1:3
    colLUT = vLUT(:,col);
    imValVolt(:,:,col) = colLUT(LR.LinearInd(imValLUT)); %gets the relevant colour gun voltage for a desired luminance value
end
if numel(imValLum)==1 %ie if just want a single value
    imValVolt=squeeze(imValVolt)'; %reduce to 1x3 number array (as old output expected)
end