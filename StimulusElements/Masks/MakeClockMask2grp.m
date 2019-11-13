function [MaskIm,mNew,nNew,GrpInd]=MakeClockMask2grp(m,n,LineLen,LineWid,CircWid,DotRad,PixelJitter,WhichStim)
% function [MaskIm,mNew,nNew,GrpInd]=MakeClockMask2grp(m,n,LineLen,LineWid,CircWid,DotRad,PixelJitter)
%
% make a mask stimulus of two groups of clock stimuli, randomly assigned (but all same luminance) - to be coloured later in code, for instance
% m/n=patchsize,RingRad,PixelJitter (how much to perturb positions), other dimensions as in DrawClock or DrawWedgeClock
% WhichStim=1 for circle clocks, 2 for wedge clocks
% returns mask image, m and n as the size dimensions are changed to fit all stimuli, plus indices of rings in each group (as cell array)
% J Greenwood 2012
%
% eg [mask,Xsize,Ysize,GrpInd]=MakeClockMask2grp(600,300,57,11,4,14,200/20,1); imshow(mask);

if ~exist('WhichStim')
    WhichStim=1;
end

ElSize = (LineLen*2)+(2*CircWid); %size of wheel elements
Xpos   = 1:ElSize:m; %X positions of unperturbed elements
Ypos   = 1:ElSize:n;
randscale = PixelJitter;%min([m n])./24; %how many pixels noise to add to x/y positions

NumRing     = length(Xpos)*length(Ypos);%round(m/TeeSize)
NumTemplate = 1; %just a ring
NumCol      = 2; %two colours to select

mNew=(Xpos(length(Xpos))+ElSize); %ensure cross images will all fit onto mask
nNew=(Ypos(length(Ypos))+ElSize);
MaskIm=zeros(nNew,mNew);
GrpIm(:,:,1)=MaskIm; %used to set indices for each group
GrpIm(:,:,2)=MaskIm;

for tt=1:NumTemplate
    if WhichStim==1 %circle clocks
        MaskWheel(:,:,tt) = DrawClockV2(ElSize+6,ElSize+6,LineLen,DotRad,CircWid,LineWid,0,1);%DrawClockV2(px,py,linelen,dotrad,circwid,linewid,orient,con)
    else %wedge clocks
        MaskWheel(:,:,tt) = DrawClockWedge(ElSize+6,ElSize+6,LineLen,DotRad,CircWid,0,1);
    end
    MaskSize = size(MaskWheel(:,:,tt));
    MaskInd(:,tt) = find(logical(MaskWheel(:,:,tt))==1);
end

TempShuf = Shuffle(All(repmat((1:NumTemplate),[1 ceil(NumRing/NumTemplate)]))); %vector for shuffling through each template ring in diff positions
GrpShuf  = Shuffle(All(repmat((1:NumCol),[1 ceil(NumRing/NumCol)]))); %vector for shuffling through each colour for rings

xc=1;yc=1;
for nc=1:NumRing
    x=0;y=0;
    while (x<1 || x>(mNew-MaskSize(2)-1))
        x = Xpos(xc) + round(randn(1,1).*randscale); %perturb positions
    end
    while (y<1 || y>(nNew-MaskSize(1)-1))
        y = Ypos(yc) + round(randn(1,1).*randscale);
    end
    MaskIm(y:y+(MaskSize(1)-1),x:x+(MaskSize(1)-1))=MaskIm(y:y+(MaskSize(1)-1),x:x+(MaskSize(1)-1))+MaskWheel(:,:,TempShuf(nc)); %add ring to region in mask image
    GrpIm(y:y+(MaskSize(1)-1),x:x+(MaskSize(1)-1),GrpShuf(nc))=GrpIm(y:y+(MaskSize(1)-1),x:x+(MaskSize(1)-1),GrpShuf(nc))+MaskWheel(:,:,TempShuf(nc)); %add just to relevant group image
    MaskIm(MaskIm>1)=1;
    GrpIm(GrpIm>1)=1;
    
    if xc==length(Xpos)
        xc=1;yc=yc+1; %loop through rows of xy
    else
        xc=xc+1;
    end
end
GrpInd = {};
for gg=1:2
    GrpInd{gg} = (find(GrpIm(:,:,gg)==1))';
end

[nNew mNew] = size(MaskIm);
