function [ArrIm,ArrInd] = DrawArrow(patchsize,ArrWid,ArrCon,bgLum,ArrAng,ArrCol)
%function to draw image of an arrow
% patchsize = imsize; ArrWid = line width; ArrCon = contrast (0-1), bgLum = background (0-1), ArrAng = angle of arrow 0-360; ArrCol = 0/[r g b];
% e.g. ArrIm = DrawArrow(200,25,0.5,0.5,30,[0.9 0.9 0]); imshow(ArrIm); % %draws a yellow arrow

patchsize=round(patchsize); ArrWid=round(ArrWid); %ensure integers for these variables
ArrIm=zeros(patchsize,patchsize,'single'); %make square patch for background %Imcent = round(size(pacIm)/2); %centre of patch
patchcent = round([patchsize patchsize]/2);
if bgLum %if non-zero bg
    ArrConCORR = (bgLum*ArrCon);
else
    ArrConCORR = ArrCon; %if background is zero, don't multply
end
HeadAng   = 90; %angle of arrowhead triangle
HeadSize  = round(ArrWid.*5);
ArrTemp   = single(DrawCirc(round(HeadSize./2),round([180-HeadAng/2 180+HeadAng/2]),patchsize,patchsize)); %arc segment for arrow head
xmin=find(sum(ArrTemp,2),1); %want to crop rounded edge as well (ie crop from min/max y position)
xmax=find(sum(ArrTemp,1),1,'last');
ymin=find(sum(ArrTemp,2),1);
ymax=find(sum(ArrTemp,2),1,'last');
ArrHead=ArrTemp(ymin:ymax,xmin:xmax); %crop out black edges
sizeHead=size(ArrHead);
ArrIm(patchcent(1)-round(0.5*ArrWid):patchcent(1)+round(0.5*ArrWid),:)=1; %draw line of arrow
ArrIm(patchcent(1)-round(0.5*sizeHead(1)):patchcent(1)-round(0.5*sizeHead(1))+sizeHead(1)-1,patchsize-sizeHead(2)+1:patchsize)=ArrHead; %add arrowhead
if ArrAng
    ArrIm = imrotate(ArrIm,ArrAng); %input in degrees
    ArrIm = imclip(ArrIm,[patchsize patchsize]);
end
ArrIm(ArrIm>1)=1; ArrIm(ArrIm<0)=0; %round

ArrInd = find(ArrIm==1); %indices for arrow pixels
bgInd   = find(ArrIm==0); %indices for bg

ArrIm = repmat(ArrIm,[1 1 3]); %repeat x3 - then either coloured or no colour
for cc=1:3 %for each rgb val
    temp = ArrIm(:,:,cc);
    if mean(ArrCol) %add colour
        temp(ArrInd) = ArrCol(cc); %not currently adding contrast for colour - %.*elConCORR;% pacIm(pacIm(:,:,cc)==0)=col(cc);
        temp(bgInd) = (ArrConCORR*(temp(bgInd)))+bgLum; %add background (or add a negative image if contrast is -ve)
    else
        temp = (ArrConCORR*(temp))+bgLum; %add background (or add a negative image if contrast is -ve)
    end
    ArrIm(:,:,cc) = temp;
end
ArrIm(ArrIm<0)=0; ArrIm(ArrIm>1)=1; %correct levels to 0-1

