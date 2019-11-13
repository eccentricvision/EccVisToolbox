function [MaskIm,mNew,nNew,GrpInd]=MakeWheelMask2grp(m,n,LineLen,LineWid,CircWid,PixelJitter)
% function [MaskIm,mNew,nNew,GrpInd]=MakeWheelMask2grp(m,n,LineLen,LineWid,CircWid,PixelJitter)
%
% make a mask stimulus of two groups of wheels, randomly assigned (but all same luminance) - to be coloured later in code, for instance
% m/n=patchsize,RingRad,PixelJitter (how much to perturb positions),
% returns mask image, m and n as the size dimensions are changed to fit all stimuli, plus indices of rings in each group (as cell array)
% J Greenwood 2012
%
% eg [mask,Xsize,Ysize,GrpInd]=MakeWheelMask2grp(600,300,55,11,3,200/20); imshow(mask);

ElSize = LineLen+(2*CircWid); %size of wheel elements
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
    MaskWheel(:,:,tt) = MakeCircleCross(ElSize+6,LineLen,LineWid,CircWid,0,0);%MakeCircleCross(PatchSize,TeeLen,TeeWid,CircWid,or1,or2)
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
