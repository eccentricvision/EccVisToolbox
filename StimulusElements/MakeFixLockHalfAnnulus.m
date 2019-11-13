function [MaskIm,xSize,ySize]=MakeFixLockHalfAnnulus(AnnRad,AnnWidth,RingRad,LineWidth,MaxDisparity,con,LRUD)
% [MaskIm,xSize,ySize]=MakeFixLockHalfAnnulus(AnnRad,AnnWidth,RingRad,LineWidth,MaxDisparity,con,LRUD)
% AnnRad,AnnWidth are for the total annulus
% RingRad,LineWidth for the constituent circles
% MaxDisparity determines the max +/- pos shifts,contrast,LRUD = 0/1/2/3 for left/right/up/down config
% returns two mask images: LE,RE
% J Greenwood May 2014
% eg [mask]=MakeFixLockHalfAnnulus(450,200,10,2,3,1,1); mask2(:,:,1) = mask(:,:,1); mask2(:,:,2) = zeros(size(mask(:,:,1))); mask2(:,:,3) = mask(:,:,2); imshow(mask2);
% or [mask,x,y]=MakeFixLockHalfAnnulus(450,200,10,2,3,1,3); mask2(:,:,1) = mask(:,:,1); mask2(:,:,2) = zeros(size(mask(:,:,1))); mask2(:,:,3) = mask(:,:,2); imshow(mask2);

if ~exist('con')
    con=1;
end

if LRUD<2 %left or right (0/1)
    xTot = AnnRad+(RingRad); %since show a half circle
    yTot = (AnnRad*2)+(RingRad*2); %full circle on the y-axis
else %up or down half-circle (2/3)
    xTot = (AnnRad*2)+(RingRad*2); %full circle on the x-axis
    yTot = AnnRad+(RingRad); %since show a half circle
end

HalfDisparity = round(0.5*MaxDisparity);

Xpos    = round(linspace(1+HalfDisparity+RingRad,xTot-((RingRad)+1+HalfDisparity),round(xTot./floor(((2*(RingRad+1)+MaxDisparity+3))))));
Ypos    = round(linspace(1+HalfDisparity+RingRad,yTot-((RingRad)+1+HalfDisparity),round(yTot./floor(((2*(RingRad+1)+MaxDisparity+3))))));
[Xp2,Yp2]   = meshgrid(Xpos,Ypos); %make x/y locations for each circle

if LRUD<2 %left or right (0/1)
    [theta,rad] = cart2pol(Xp2(:)-1,Yp2(:)-AnnRad-RingRad); %convert to polar coordinates in a single vector
else %up or down half-circle (2/3)
    [theta,rad] = cart2pol(Xp2(:)-AnnRad-RingRad,Yp2(:)-1); %convert to polar coordinates in a single vector
end
Ind         = find(rad<(AnnRad-1) & rad>(AnnRad-AnnWidth));
Xpos        = All(Xp2(Ind));
Ypos        = All(Yp2(Ind));

NumRing     = numel(Xpos);%*length(Ypos);%round(m/TeeSize)

%make ring template
maskring = DrawRing(RingRad,RingRad-LineWidth,[0 360],(RingRad+1)*2,(RingRad+1)*2,con);
ringsize = size(maskring);

DXs = Shuffle(repmat([-1 0 1],[1 ceil(NumRing/3)+1])); %-1 is far, 0 no depth, 1=near

MaskIm=zeros(yTot,xTot,2);

%make annulus image

%xc=1;yc=1;
for nc=1:NumRing
    xLE=0; xRE=0; y=0;
    xLE = Xpos(nc) + round(DXs(nc).*HalfDisparity) - RingRad; %shift circle if necessary for depth
    xRE = Xpos(nc) - round(DXs(nc).*HalfDisparity) - RingRad; %RE version
    y   = Ypos(nc) - RingRad; %regular structure on y axis
    
    MaskIm(y:y+(ringsize(1)-1),xLE:xLE+(ringsize(2)-1),1)=MaskIm(y:y+(ringsize(1)-1),xLE:xLE+(ringsize(2)-1),1) + maskring; %left eye
    MaskIm(y:y+(ringsize(1)-1),xRE:xRE+(ringsize(2)-1),2)=MaskIm(y:y+(ringsize(1)-1),xRE:xRE+(ringsize(2)-1),2) + maskring; %right eye
end

MaskIm(MaskIm>1)=1;
MaskIm(MaskIm>con)=con; %correct for overlapping contrast regions

if LRUD==1 %right-side (need to flip left image)
    for ii=1:2
        MaskIm(:,:,ii) = fliplr(MaskIm(:,:,ii));
    end
elseif LRUD==3 %upper-side (need to flip lower image)
    for ii=1:2
        MaskIm(:,:,ii) = flipud(MaskIm(:,:,ii));
    end
end

[ySize,xSize,zSize] = size(MaskIm);
