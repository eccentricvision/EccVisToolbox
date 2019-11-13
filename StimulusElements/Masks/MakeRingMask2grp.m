function [MaskIm,mNew,nNew,GrpInd]=MakeRingMask2grp(m,n,RingRad,PixelJitter)
% function [MaskIm,mNew,nNew,GrpInd]=MakeRingMask2grp(m,n,RingRad,PixelJitter)
%
% make a mask stimulus of two groups of rings, randomly assigned (but all same luminance) - to be coloured later in code, for instance
% m/n=patchsize,RingRad,PixelJitter (how much to perturb positions),
% returns mask image, m and n as the size dimensions are changed to fit all stimuli, plus indices of rings in each group (as cell array)
% J Greenwood 2012
%
% eg [mask,Xsize,Ysize,GrpInd]=MakeRingMask2grp(400,200,20,200/20); imshow(mask);

LineWidth = RingRad/2.5; %line width always multiples of 5 to the diameter

Xpos=1:floor(2*(RingRad+1)):m;
Ypos=1:floor(2*(RingRad+1)):n;
randscale = PixelJitter;%min([m n])./24; %how many pixels noise to add to x/y positions

NumRing     = length(Xpos)*length(Ypos);%round(m/TeeSize)
NumTemplate = 1; %just a ring
NumCol      = 2; %two colours to select

mNew=(Xpos(length(Xpos))+((2*RingRad+1))); %ensure cross images will all fit onto mask
nNew=(Ypos(length(Ypos))+((2*RingRad+1)));
MaskIm=zeros(nNew,mNew);
GrpIm(:,:,1)=MaskIm; %used to set indices for each group
GrpIm(:,:,2)=MaskIm;

for tt=1:NumTemplate
    MaskRing(:,:,tt) = (DrawRing(RingRad,RingRad-LineWidth,[0 360],(RingRad+1)*2,(RingRad+1)*2,1));
    MaskSize = size(MaskRing(:,:,tt));
    MaskInd(:,tt) = find(round(MaskRing(:,:,tt))==1);
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
    MaskIm(y:y+(MaskSize(1)-1),x:x+(MaskSize(1)-1))=MaskIm(y:y+(MaskSize(1)-1),x:x+(MaskSize(1)-1))+MaskRing(:,:,TempShuf(nc)); %add ring to region in mask image
    GrpIm(y:y+(MaskSize(1)-1),x:x+(MaskSize(1)-1),GrpShuf(nc))=GrpIm(y:y+(MaskSize(1)-1),x:x+(MaskSize(1)-1),GrpShuf(nc))+MaskRing(:,:,TempShuf(nc)); %add just to relevant group image
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
