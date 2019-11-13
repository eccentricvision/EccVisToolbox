function [MaskIm,mNew,nNew]=MakeRingMask(m,n,RingRad,PixelJitter,con)
%m/n=patchsize,RingRad,PixelJitter (how much to perturb positions),contrast
%returns mask image, m and n as the size dimensions are changed to fit all stimuli
% eg [mask,Xsize,Ysize]=MakeRingMask(400,200,20,200/20,1); imshow(mask);

if ~exist('con')
    con=1;
end

LineWidth = RingRad/2.5; %line width always multiples of 5 to the diameter
mscaleX = m/(m);% + ((2*RingRad+1)+1)*0.75); %scaling factor for masksize with a higher no of elements
mscaleY = n/(n);% + ((2*RingRad+1)+1)*0.75);
SizeMult = 2; %multiplier for size of each cross element on the final mask

Xpos=1:floor(((2*(RingRad+1)))*mscaleX):m;
Ypos=1:floor(((2*(RingRad+1)))*mscaleY):n;
randscale = PixelJitter;%min([m n])./24; %how many pixels noise to add to x/y positions

NumRing=length(Xpos)*length(Ypos);%round(m/TeeSize)
NumTemplate=1;

mNew=(Xpos(length(Xpos))+((2*RingRad+1))); %ensure cross images will all fit onto mask
nNew=(Ypos(length(Ypos))+((2*RingRad+1)));
MaskIm=zeros(nNew,mNew);

for cc=1:NumTemplate
    maskring(:,:,cc) = DrawRing(RingRad,RingRad-LineWidth,[0 360],(RingRad+1)*2,(RingRad+1)*2,1);
    masksize = size(maskring(:,:,cc));
end
TempShuf=Shuffle(All(repmat((1:NumTemplate),[1 ceil(NumRing/NumTemplate)]))); %vector for shuffling through each template ring in diff positions
xc=1;yc=1;
for nc=1:NumRing
    x=0;y=0;
    while (x<1 || x>(mNew-masksize(2)-1))
        x = Xpos(xc) + round(randn(1,1).*randscale); %perturb positions
    end
    while (y<1 || y>(nNew-masksize(1)-1))
        y = Ypos(yc) + round(randn(1,1).*randscale);
    end
    %x(x<1)=1; x(x>(mNew-masksize(2)-1))=mNew-masksize(2)-1; %clip
    %y(y<1)=1; y(y>(nNew-masksize(1)-1))=nNew-masksize(1)-1; %clip
    MaskIm(y:y+(masksize(1)-1),x:x+(masksize(1)-1))=MaskIm(y:y+(masksize(1)-1),x:x+(masksize(1)-1)) + maskring(:,:,TempShuf(nc));
    MaskIm(MaskIm>1)=1;
    if xc==length(Xpos)
        xc=1;yc=yc+1; %loop through rows of xy
    else
        xc=xc+1;
    end
    MaskIm(MaskIm>con)=con; %correct for overlapping contrast regions
end

%MaskIm = ImClip(MaskIm,[n+ceil(2*(RingRad+1)) m+ceil(2*(RingRad+1))]);
[nNew mNew] = size(MaskIm);
