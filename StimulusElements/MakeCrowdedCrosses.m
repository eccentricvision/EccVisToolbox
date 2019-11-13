function [target,newImSize]=MakeCrowdedCrosses(m,n,TeeSize,TeeOff1,TeeOff2,TeeOr1,TeeOr2,Sep,Sd1,c1,c2,OStart)
% t=MakeCrowdedCrosses(256,256,55,[0 0 0 0 0],[0 0 0 0 0],0,0,80,0,[-1 1 1 1 1],[1 1 1 1 1]); t=t+0.5; imshow(t)
% t=MakeCrowdedCrosses(256,256,45,[0.3.*(1-2.*rand(1,9))],[0.5.*(1-2.*rand(1,9))],[DegToRad(10).*(1-2.*rand(1,9))],[DegToRad(10).*(1-2.*rand(1,9))],70,0,ones(1,9),ones(1,9)); ishow(t)
%also now returns newImSize = modified size of patch given both TeeSize and TeeSep
%fixed to give independent control of m and n values

MinSize=ceil(3.25*TeeSize)+2*Sep;

if length(TeeOr1)<length(TeeOff1)
    TeeOr1=TeeOr1(1)+zeros(1,length(TeeOff1));
end
if length(TeeOr2)<length(TeeOff1)
    TeeOr2=TeeOr2(1)+zeros(1,length(TeeOff1));
end

subim=MakeSubPixCross2(TeeSize,TeeSize*2,5,(0.4*TeeSize*TeeOff1),(0.4*TeeSize*TeeOff2),TeeOr1,TeeOr2,c1,c2); %make all crosses
NumCrosses = length(TeeOff1); %number of crosses
target = PadIm(subim(:,:,1),[MinSize MinSize],0); %add zeros around centre target
OrStep=DegToRad(360/(NumCrosses-1)); %determines where on clockface flankers are placed - 0deg is right of target, equal steps around the clock for each flank
FlankDist=Sep;
if ~exist('OStart')
    OStart=pi/2+0*rand*2*pi;
end
for i=1:NumCrosses %cycle through each cross %NoFlanks %cycle through flanks
    %subim=MakeSubPixCross2(TeeSize,TeeSize*2,5,(0.4*TeeSize*TeeOff1(i+1)),(0.4*TeeSize*TeeOff2(i+1)),TeeOr1(i+1),TeeOr2(i+1),c1(i+1),c2(i+1));
    if Sd1>0
        subim(:,:,i)=rmsNorm(DoLog(subim(:,:,i),Sd1));
    end
    if i==1 %target
        target=PadIm(subim(:,:,i),[MinSize MinSize],0); %add zeros around centre target
    else
        FlankAng=OStart+(i-2)*OrStep;
        pX=round(((MinSize/2)+cos(FlankAng).*FlankDist)-TeeSize*1)+1;
        pY=round(((MinSize/2)+sin(FlankAng).*FlankDist)-TeeSize*1)+1;
        target(pX:pX+TeeSize*2-1,pY:pY+TeeSize*2-1)= target(pX:pX+TeeSize*2-1,pY:pY+TeeSize*2-1)+subim(:,:,i);
    end
end
if m<MinSize
    target=ImClip(target,[m n]);
else
    target=PadIm(target,[m n]);
end
newImSize=length(target); %size of target image returned (to ensure any changes are monitored)
