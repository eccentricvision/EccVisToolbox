function [LineIm,LineInd]=DrawVernier(PatchSize,LineLen,LineWid,UpperShift,LowerShift,VertLineGap,ori)
%function [LineIm,LineInd]=DrawVernier(PatchSize,LineLen,LineWid,TopShift,BottomShift,VertLineGap,ori)
% draw a two-line vernier element on a patch with a given length, width and offset
%
% PatchSize = total size of image, LineLen = length of lines, LineWid = width of lines,
% UpperShift = [-x 0 or +x] horizontal offset of top line, LowerShift = likewise for bottom line,
% VertLineGap = space between upper and lower line, ori = orientation (deg)
% returns LineIm (image) and LineInd which indexes the pixels for the element
% NB. image only progresses in steps of 2 for line width/length and vertgap due to meshgrid setup
% (recommend drawing at 2x required size and reducing in PTB for stimulus presentation)
%
% J Greenwood 2019
%
% eg 1: [LineIm,LineInd]=DrawVernier(200,40,10,-10,0,20,0); imshow(LineIm);
% eg 2: [LineIm,LineInd]=DrawVernier(200,50,20,20,0,20,0); imshow(LineIm);

%make a meshgrid
halfpx        = (PatchSize/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy        = (PatchSize/2)-0.5;
[meshX,meshY] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle

%line params
HalfWid     = (LineWid/2); %half width of line
HalfLen     = (LineLen/2); %half length

UpperLineXX = [UpperShift-HalfWid UpperShift+HalfWid]; %startX to finish X
UpperLineYY = [0-(0.5*VertLineGap)-LineLen 0-(0.5*VertLineGap)]; %startY to finish Y
LowerLineXX = [LowerShift-HalfWid LowerShift+HalfWid];
LowerLineYY = [0+(0.5*VertLineGap) 0+(0.5*VertLineGap)+LineLen];

%draw the lines
LineIm = zeros(PatchSize,PatchSize);
LineIm(meshX>UpperLineXX(1) & meshX<UpperLineXX(2) & meshY>UpperLineYY(1) & meshY<UpperLineYY(2)) = 1; %make the upper line
LineIm(meshX>LowerLineXX(1) & meshX<LowerLineXX(2) & meshY>LowerLineYY(1) & meshY<LowerLineYY(2)) = 1; %make the lower line

%rotate line to finish
if ori>0
    LineIm  = imrotate(LineIm,ori,'crop'); %rotates each element
end
LineInd = logical(LineIm); %convert to 0s & 1s