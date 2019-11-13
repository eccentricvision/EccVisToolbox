function [imValVolt]=BitStealVal_old(imValLum,LR,vLUT)
% bitstealing code for luminance values (0-1), returning an RGB array as imValVolt
% need to already have loaded load('C:\Users\JohnG\Matlab Files\Calibration\BitStealCal3D.mat');
% or similar and have a LR structure
% and run InitialiseBitSteal to generate vLUT
% J Greenwood 2010 modified from code by Steven Dakin
% modified Sept 2014 to allow computation of a whole image at once

displayableL=LR.VtoLfunR(LR,vLUT(:,1)')+LR.VtoLfunG(LR,vLUT(:,2)')+LR.VtoLfunB(LR,vLUT(:,3)');
imValLum = imValLum.*max(displayableL); %convert to displayable luminance range
ImSize = size(imValLum);
uniqueVals = unique(imValLum); %how many contrast values requested

imValVolt = zeros(ImSize(1),ImSize(2),3);%create blank array
for uu=1:numel(uniqueVals)
%for row=1:ImSize(1)
%    for col=1:ImSize(2)
        %[minVal, minInd(row,col)]=min(abs(imValLum(row,col)-displayableL));
%    end
    [minVal,minInd] = min(abs(uniqueVals(uu)-displayableL));
    ImInd = find(imValLum==uniqueVals(uu)); %indices for the current contrast level
    
    for cc=1:3
        tempIm            = imValVolt(:,:,cc);
        tempIm(ImInd)     = vLUT(minInd,cc)';
        imValVolt(:,:,cc) = tempIm;
        %imValVolt(row,:,cc)=vLUT(minInd(row,:),cc)';
    end
end
if numel(imValLum)==1 %ie if just want a single value
    imValVolt=squeeze(imValVolt)'; %reduce to 1x3 number array (as old output expected)
end