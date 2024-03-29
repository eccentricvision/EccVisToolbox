function [MaskIm,mNew,nNew]=MakeLineMask2(m,n,TeeSize,NumTemplate,con)
%m/n=patchsize,TeeSize,NumTemp=no of cross templates tiled (min of ~9), orientation,contrast
%all lines are cardinal. If not, input range e.g. [-15 15] of rotations to apply
%returns mask image, m and n as the size dimensions are changed to fit all stimuli
%eg with random rotations:  [mask,Xsize,Ysize]=MakeLineMask2(400,200,55,9,1); imshow(mask);
%generates an image of randomly positioned line elements similar to MakeCrowdedCrosses

if ~exist('con')
    con=1;
end

TeeWidth = TeeSize/5; %always multiples of 5
mscaleX = m/(m + (TeeSize+1)); %scaling factor for masksize with a higher no of elements
mscaleY = n/(n + (TeeSize+1));
SizeMult = 2; %multiplier for size of each cross element on the final mask
BigPatch = round(TeeSize*SizeMult);

Xpos=1:floor((TeeSize)*mscaleX):m;
Ypos=1:floor((TeeSize)*mscaleY):n;
NumCross=length(Xpos)*length(Ypos);%round(m/TeeSize)
%NumTemplate=ceil(NumCross/length(Xpos)); %number of crosses to tile across image

mNew=(Xpos(length(Xpos))+(BigPatch)); %ensure cross images will all fit onto mask
nNew=(Ypos(length(Ypos))+(BigPatch));
MaskIm=zeros(nNew,mNew);

LinesPx=Shuffle(round((-0.4*(TeeSize)):((0.8*(TeeSize))/NumTemplate):(0.4*(TeeSize+1)))); %generate Xpos for template crosses
LinesPy=Shuffle(round((-0.4*(TeeSize)):((0.8*(TeeSize))/NumTemplate):(0.4*(TeeSize+1))));

for cc=1:NumTemplate
    maskcross(:,:,cc)=MakeSubPixCross3(TeeSize,BigPatch,5,LinesPx(cc),LinesPy(cc),con,con); %make template crosses
    masksize = size(maskcross(:,:,cc));
end

TempShuf=Shuffle(All(repmat((1:NumTemplate),[1 ceil(NumCross/NumTemplate)]))); %vector for shuffling through each template cross in diff positions
xc=1;yc=1;
for nc=1:NumCross
    MaskIm(Ypos(yc):Ypos(yc)+(masksize(1)-1),Xpos(xc):Xpos(xc)+(masksize(1)-1))=...
        MaskIm(Ypos(yc):Ypos(yc)+(masksize(1)-1),Xpos(xc):Xpos(xc)+(masksize(1)-1)) + maskcross(:,:,TempShuf(nc));
    MaskIm(MaskIm>1)=1;
    if xc==length(Xpos)
        xc=1;yc=yc+1; %loop through rows of xy
    else
        xc=xc+1;
    end
    MaskIm(MaskIm>con)=con; %correct for overlapping contrast regions
end

%MaskIm = ImClip(MaskIm,[n+ceil(TeeSize) m+ceil(TeeSize)]);
[nNew mNew] = size(MaskIm);
%[LinesPx LinesPy]=MakeDensePositionGrid(m-(TeeSize*2),n-(TeeSize*2),MinDist); %reduced Line positions to ensure none placed outside masking region
%imshow(MaskIm)
