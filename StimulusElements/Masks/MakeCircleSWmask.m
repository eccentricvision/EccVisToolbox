function [MaskIm,mNew,nNew,GrpInd]=MakeCircleSWmask(m,n,GratRad,Theta,Lambda,Phase,NumHarmonics,CircWid,PixelJitter)
% function [MaskIm,mNew,nNew,GrpInd]=MakeCircleSWmask(m,n,GratRad,Theta,Lambda,Phase,NumHarmonics,CircWid,PixelJitter)
%
% make a mask stimulus of x groups of circular square wave stimuli, randomly assigned (but all same luminance) - to be coloured later in code, for instance
% m/n=patchsize,GratRad,Theta,Lambda,Phase,NumHarmonics,CircWid,PixelJitter (how much to perturb positions),
% returns mask image, m and n as the size dimensions are changed to fit all stimuli, plus indices of gratings in each group (as cell array)
% J Greenwood 2012
%
% eg  [mask,Xsize,Ysize,GrpInd]=MakeCircleSWmask(600,300,58,[-45 45],14,pi/2,5,17,10); imshow(mask);
% eg2 [mask,Xsize,Ysize,GrpInd]=MakeCircleSWmask(600,300,58,[-45 45],14,pi/2,5,0,20); imshow(mask);

ElSize = 2*GratRad+(2*CircWid); %size of wheel elements
Xpos   = 1:ElSize:m; %X positions of unperturbed elements
Ypos   = 1:ElSize:n;
randscale = PixelJitter;%min([m n])./24; %how many pixels noise to add to x/y positions

NumElements     = length(Xpos)*length(Ypos);%round(m/TeeSize)
NumTemplate = numel(Theta); %two orientations
NumCol      = 1; %one colour to select

mNew=(Xpos(length(Xpos))+ElSize); %ensure cross images will all fit onto mask
nNew=(Ypos(length(Ypos))+ElSize);
MaskIm=zeros(nNew,mNew);
for tt=1:NumTemplate
    GrpIm(:,:,tt)=MaskIm; %used to set indices for each group
    
    MaskElement(:,:,tt) = MakeOutlinedSquareWaveBW(((GratRad+CircWid)*2)+6,GratRad,Theta(tt),Lambda,Phase,NumHarmonics,1,CircWid); %MakeOutlinedSquareWave(patchsize,gratRad,theta,lambda,phase,numharmonics,con,lineWid,cols)
    MaskSize = size(MaskElement(:,:,tt));
end

TempShuf = Shuffle(All(repmat((1:NumTemplate),[1 ceil(NumElements/NumTemplate)]))); %vector for shuffling through each template ring in diff positions
GrpShuf  = Shuffle(All(repmat((1:NumTemplate),[1 ceil(NumElements/NumTemplate)]))); %vector for shuffling through each colour for rings

xc=1;yc=1;
for nc=1:NumElements
    x=0;y=0;
    while (x<1 || x>(mNew-MaskSize(2)-1))
        x = Xpos(xc) + round(randn(1,1).*randscale); %perturb positions
    end
    while (y<1 || y>(nNew-MaskSize(1)-1))
        y = Ypos(yc) + round(randn(1,1).*randscale);
    end
    MaskIm(y:y+(MaskSize(1)-1),x:x+(MaskSize(1)-1))=MaskIm(y:y+(MaskSize(1)-1),x:x+(MaskSize(1)-1))+MaskElement(:,:,TempShuf(nc)); %add ring to region in mask image
    GrpIm(y:y+(MaskSize(1)-1),x:x+(MaskSize(1)-1),GrpShuf(nc))=GrpIm(y:y+(MaskSize(1)-1),x:x+(MaskSize(1)-1),GrpShuf(nc))+MaskElement(:,:,TempShuf(nc)); %add just to relevant group image
    MaskIm(MaskIm>1)=1;
    GrpIm(GrpIm>1)=1;
    
    if xc==length(Xpos)
        xc=1;yc=yc+1; %loop through rows of xy
    else
        xc=xc+1;
    end
end
GrpInd = {};
for gg=1:NumTemplate
    GrpInd{gg} = (find(GrpIm(:,:,gg)==1))';
end

[nNew mNew] = size(MaskIm);
