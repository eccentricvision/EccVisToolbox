function [CrossIm]=MakeCrossElements(PatchSize,TeeSize,NumCross,Xoff,Yoff,TeeOr1,TeeOr2,con)

%input = patchsize (x,y),TeeSize,NumCross=no of cross templates, Xoffset array, Yoffset array, orientation array (in deg, to be converted),contrast array
%if TeeOr1/2 input as 0, all lines are cardinal. 
%input con as two numbers for each element eg. [0.5 1] for one element or [0.5 1; 1 1] for two
%returns array of cross image(s)
%
%J Greenwood 2009
%
% eg: %[CrossIm]=MakeCrossElements([57 124],55,9,linspace(-1,1,9),linspace(-0.5,0.5,9),0,0,[1 1]); for cc=1:9; subplot(3,3,cc); imshow(CrossIm(:,:,cc));end;
% eg2: [CrossIm]=MakeCrossElements([150 150],55,1,0,0,0,0,[1 1]); imshow(CrossIm);

%if drawing multiple crosses, make sure there's enough input parameters for each dimension
while length(Xoff)<NumCross %spin out each variable length to ensure each is an array (one for each cross if you're making multiple crosses - if not, make equivalent to first cross)
    Xoff(length(Xoff)+1) = Xoff(1);
end
while length(Yoff)<NumCross
    Yoff(length(Yoff)+1) = Yoff(1);
end
while length(TeeOr1)<NumCross
    TeeOr1(length(TeeOr1)+1) = TeeOr1(1);
end
while length(TeeOr2)<NumCross
    TeeOr2(length(TeeOr2)+1) = TeeOr2(1);
end

dim = size(con);
if dim(2)==1
    con = [con con]; %double to give contrast of each element/stroke in the T (can have opposite contrasts for the strokes)
end

while dim(1)<NumCross
    con(dim(1)+1,:) = [con(1,1) con(1,2)];
    dim = size(con);
end
if length(PatchSize)<2 %only one input for patchsize
    PatchSize(2) = PatchSize(1);
end
TeeProp = 5; %always multiples of 5 (ie 5x longer than width)
CrossIm=zeros(PatchSize(2),PatchSize(1),NumCross);

%now make the crosses
for cc=1:NumCross
    CrossIm(:,:,cc)=MakeSubPixCross2(TeeSize,PatchSize,TeeProp,Xoff(cc).*(0.4*TeeSize),Yoff(cc).*(0.4*TeeSize),deg2rad(TeeOr1(cc)),deg2rad(TeeOr2(cc)),con(cc,1),con(cc,2)); %make template crosses
end

