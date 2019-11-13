function [LineIm,LineInd]=DrawLineElement(PatchSize,LineLen,LineWid,ori)
%function [LineIm,LineInd]=DrawLineElement(PatchSize,LineLen,LineWid,ori)
% draw a line element on a patch with a given length, width and orientation
%
% J Greenwood 2013
%
% PatchSize = total size of image, LineLen = length of lines, LineWid = width of lines, ori = orientation (in deg 0-360)
% returns LineIm (image) and LineInd which indexes the pixels for the element
%
% eg 1: [LineIm,LineInd]=DrawLineElement(120,80,5,45); imshow(LineIm); 
% eg 2: [LineIm,LineInd]=DrawLineElement(120,40,10,270); imshow(LineIm);

%make a meshgrid
halfpx        = (PatchSize/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy        = (PatchSize/2)-0.5;
[meshX,meshY] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle

%make the line
HalfLen   = (LineLen/2);
HalfWid   = (LineWid/2);
Line      = zeros(PatchSize,PatchSize);
Line(meshX>-HalfLen & meshX<HalfLen & meshY>-HalfWid & meshY<HalfWid) = 1;

%rotate line to finish
LineIm  = imrotate(Line,ori,'crop'); %rotates each element
LineInd = logical(LineIm); %convert to 0s & 1s