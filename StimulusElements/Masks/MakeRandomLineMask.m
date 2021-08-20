function [MaskIm,mNew,nNew]=MakeRandomLineMask(PatchX,PatchY,LineLength,orient,con)
% [MaskIm,mNew,nNew]=MakeRandomLineMask(PatchX,PatchY,LineLength,orient,con)
% derived from MakeLineMask and MakeLineMask2 (which actually use crosses) - here just randomly placed line strokes
% input PatchX/Y=patchsize,LineLength (width = 1/5 length), orient is an array of deg vals e.g. [0 90], contrast
% returns mask image, m and n as the size dimensions are changed to fit all stimuli
%
% e.g. [mask,Xsize,Ysize]=MakeRandomLineMask(400,200,55,[0 90],1); imshow(mask);
%
% J Greenwood July 2021

if ~exist('con')
    con=1;
end

%set up parameters for line image
LineWidth = LineLength/5; %always multiples of 5
PatchSize = LineLength+2; %patch size for line element
if mod(PatchSize,2) %make sure it's an even number
    PatchSize = PatchSize+1;
end
NumLineIm = numel(orient); %how many images to draw (one per orientation)

%draw the line element (to be repeated across the image)
for nl=1:NumLineIm
    LineIm(:,:,nl) = DrawLineElement(PatchSize,LineLength,LineWidth,orient(nl));
end
masksize = size(LineIm);
halfx    = round(masksize(2)/2);
halfy    = round(masksize(1)/2);

%set up the overall mask image parameters
PatchXnew=round(PatchX+(masksize(2)*2)); %make sure the images will fit
PatchYnew=round(PatchY+(masksize(1)*2));
LineXspace = LineWidth*1; %horizontal gap between lines
LineYspace = LineLength*1.25; %vertical gap

XranMax    = LineWidth; %how much jitter to add to line positions
YranMax    = LineLength;

%work out the positions of the lines (as a regular grid)
Xrow=(floor(1+masksize(2)/2):LineXspace:PatchXnew-ceil(masksize(2)/2)-1); %sets the values of X position in each row
Yrow=floor(1+masksize(1)/2):LineYspace:PatchYnew-ceil(masksize(1)/2)-1; %sets the y position of each row
NumLine=length(Xrow)*length(Yrow);%round(m/TeeSize)

for yy=1:numel(Yrow) %determine positions for each line in each row and add jitter
    %add jitter to line positions
    LinePosX(yy,:)    = round(Xrow+(randn(1,length(Xrow)).*XranMax)); %all the X positions within this row
    LinePosY(yy,:)    = round((Yrow(yy).*ones(1,length(Xrow)))+(randn(1,length(Xrow)).*YranMax)); %corresponding Y positions for these lines (with jitter individually added to break up the row)
    WhichOrient(yy,:) = randi(NumLineIm,[1 length(Xrow)]); %which orientation for each line
end

%make sure randomised positions are within range for image placement
LinePosX(LinePosX<min(Xrow))=min(Xrow);
LinePosX(LinePosX>max(Xrow))=max(Xrow);
LinePosY(LinePosY<min(Yrow))=min(Yrow);
LinePosY(LinePosY>max(Yrow))=max(Yrow);

%revise the size of the mask to centre the lines
PatchXnew=round(max(LinePosX(:))+(masksize(2)/2)); %make sure the images will fit
PatchYnew=round(max(LinePosY(:))+(masksize(1)/2));

MaskIm=zeros(PatchYnew,PatchXnew);
xc=1;yc=1;
for yy=1:numel(Yrow)
    for xx=1:numel(Xrow)
        MaskIm(LinePosY(yy,xx)-halfy:LinePosY(yy,xx)-halfy+(masksize(1)-1),LinePosX(yy,xx)-halfx:LinePosX(yy,xx)-halfx+(masksize(2)-1))=...
            MaskIm(LinePosY(yy,xx)-halfy:LinePosY(yy,xx)-halfy+(masksize(1)-1),LinePosX(yy,xx)-halfx:LinePosX(yy,xx)-halfx+(masksize(2)-1)) + LineIm(:,:,WhichOrient(yy,xx));
    end
end
MaskIm(MaskIm>1)=1; %correct for range
MaskIm(MaskIm>con)=con; %correct for overlapping contrast regions

%MaskIm = ImClip(MaskIm,[n+ceil(TeeSize) m+ceil(TeeSize)]);
[nNew mNew] = size(MaskIm);
%[LinesPx LinesPy]=MakeDensePositionGrid(m-(TeeSize*2),n-(TeeSize*2),MinDist); %reduced Line positions to ensure none placed outside masking region
%imshow(MaskIm)
