function [MaskIm,mNew,nNew,ColInd]=MakeRingMaskCol(m,n,RingRad,PixelJitter,bg,cols)
% function [MaskIm,mNew,nNew,ColInd]=MakeRingMaskCol(m,n,RingRad,PixelJitter,cols)
%
% make a mask stimulus of rings in one of two colours, randomly assigned
% m/n=patchsize,RingRad,PixelJitter (how much to perturb positions),
% background luminance, cols = 2x3 array of two colours (usually red/green) for rings
% returns mask image, m and n as the size dimensions are changed to fit all stimuli, plus indices of rings in each colour range (as cell)
% J Greenwood 2012
%
% eg [mask,Xsize,Ysize,ColInd]=MakeRingMaskCol(400,200,20,200/20,0.5,[1 0 0; 0 1 0; 0.5 0.5 0.5]); imshow(mask);

if ~exist('bg')
    bg=0;
end
if ~exist('cols')
    cols = [1 1 1; 1 1 1];
end

LineWidth = RingRad/2.5; %line width always multiples of 5 to the diameter
mscaleX = m/(m);% + ((2*RingRad+1)+1)*0.75); %scaling factor for masksize with a higher no of elements
mscaleY = n/(n);% + ((2*RingRad+1)+1)*0.75);
SizeMult = 2; %multiplier for size of each cross element on the final mask

Xpos=1:floor(((2*(RingRad+1)))*mscaleX):m;
Ypos=1:floor(((2*(RingRad+1)))*mscaleY):n;
randscale = PixelJitter;%min([m n])./24; %how many pixels noise to add to x/y positions

NumRing     = length(Xpos)*length(Ypos);%round(m/TeeSize)
NumTemplate = 1; %just a ring
NumCol      = 2; %two colours to select

mNew=(Xpos(length(Xpos))+((2*RingRad+1))); %ensure cross images will all fit onto mask
nNew=(Ypos(length(Ypos))+((2*RingRad+1)));
MaskIm=zeros(nNew,mNew,3)+bg;
col1im=MaskIm(:,:,1); %used to set indices for each colour
col2im=MaskIm(:,:,1);

MaskRing = {};
for tt=1:NumTemplate
    MaskRing{tt} = int8(DrawRing(RingRad,RingRad-LineWidth,[0 360],(RingRad+1)*2,(RingRad+1)*2,1));
    MaskSize = size(MaskRing{tt});
    MaskInd(:,tt) = find(boolean(MaskRing{tt})==1);
end

TempShuf = Shuffle(All(repmat((1:NumTemplate),[1 ceil(NumRing/NumTemplate)]))); %vector for shuffling through each template ring in diff positions
ColShuf  = Shuffle(All(repmat((1:NumCol),[1 ceil(NumRing/NumCol)]))); %vector for shuffling through each colour for rings

xc=1;yc=1;
for nc=1:NumRing
    x=0;y=0;
    while (x<1 || x>(mNew-MaskSize(2)-1))
        x = Xpos(xc) + round(randn(1,1).*randscale); %perturb positions
    end
    while (y<1 || y>(nNew-MaskSize(1)-1))
        y = Ypos(yc) + round(randn(1,1).*randscale);
    end

    for cc=1:3
        tempIm = MaskIm(y:y+(MaskSize(1)-1),x:x+(MaskSize(1)-1),cc); %take a subset of the pixels
        tempIm(MaskInd(:,TempShuf(nc))) = (MaskRing{TempShuf(nc)}(MaskInd(:,TempShuf(nc)))).*cols(ColShuf(nc),cc); %just colour the relevant pixels
        MaskIm(y:y+(MaskSize(1)-1),x:x+(MaskSize(1)-1),cc) = tempIm; %replace the patch
        MaskIm(MaskIm>1)=1;
    end
    
    if xc==length(Xpos)
        xc=1;yc=yc+1; %loop through rows of xy
    else
        xc=xc+1;
    end
end
ColInd = {};
for cc=1:3
    ColInd{cc} = find(round(MaskIm(:,:,cc).^3)==1); %indices for elements within each colour plane (use .^3 instead of boolean due to the background being there)
end

[nNew mNew] = size(MaskIm);
