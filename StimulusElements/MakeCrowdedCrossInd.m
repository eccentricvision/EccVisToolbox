function target=MakeCrowdedCrossInd(m,n,TeeSize,TeeOff1,TeeOff2,TeeOr1,TeeOr2,Sep,Sd1,c1,c2,OStart)
% t=MakeCrowdedCrossInd(512,100,55,[0 0 0],[0 0 0],0,0,80,0,1,1,pi); imshow(t)
% t=MakeCrowdedCrossInd(256,256,45,[0.3.*(1-2.*rand(1,9))],[0.5.*(1-2.*rand(1,9))],[DegToRad(10).*(1-2.*rand(1,9))],[DegToRad(10).*(1-2.*rand(1,9))],70,0,1,1); ishow(t)
% modified version of Steven's MakeCrowdedCrosses code, now with more independent control of X and Y axes in patch size

if ~exist('OStart')
    OStart=pi/2+0*rand*2*pi;
end
NoFlanks=length(TeeOff1)-1; %subtract target cross from numflanks
if NoFlanks>2 %more than 2 flanks plus target = need larger size patch, more rectangular most likely
    MinSizeX=(3*TeeSize)+(2*Sep)+10;
    MinSizeY=(3*TeeSize)+(2*Sep)+10;
else %2 or less flanks, can have more rectangular patch
    switch OStart
        case {0 abs(pi)} %begin to the left/right - need larger X axis
            MinSizeX=(3*TeeSize)+(2*Sep)+10;
            MinSizeY=n;
        case abs(pi/2) %begin up/down
            MinSizeX=m;
            MinSizeY=(3*TeeSize)+(2*Sep)+10;
        otherwise %intermediate flank start = probably need square image
            MinSizeX=(3*TeeSize)+(2*Sep)+10;
            MinSizeY=(3*TeeSize)+(2*Sep)+10;
    end
end
if length(TeeOr1)<length(TeeOff1)
    TeeOr1=TeeOr1(1)+zeros(1,length(TeeOff1));
end
if length(TeeOr2)<length(TeeOff1)
    TeeOr2=TeeOr2(1)+zeros(1,length(TeeOff1));
end
TeeImSize=round(TeeSize*1.2); %size of patch for Tee stimuli
subim=MakeSubPixCross2(TeeSize,TeeImSize,5,(0.4*TeeSize*TeeOff1(1)),(0.4*TeeSize*TeeOff2(1)),TeeOr1(1),TeeOr2(1),c1,c2); %make target cross
if Sd1>0
    subim=rmsNorm(DoLog(subim,Sd1));
end
target=PadIm(subim,[MinSizeY MinSizeX],0);
OrStep=DegToRad(360/NoFlanks); %determines where on clockface flankers are placed - 0deg is right of target, equal steps around the clock for each flank

for i=1:NoFlanks %cycle through flanks
    subim=MakeSubPixCross2(TeeSize,TeeImSize,5,(0.4*TeeSize*TeeOff1(i+1)),(0.4*TeeSize*TeeOff2(i+1)),TeeOr1(i+1),TeeOr2(i+1),c1,c2);
    if Sd1>0
        subim=rmsNorm(DoLog(subim,Sd1));
    end
    FlankAng=OStart+(i-1)*OrStep; FlankDist=Sep;
    pX=round(((MinSizeX/2)+cos(FlankAng).*FlankDist)-(0.5*TeeImSize))+1;
    pY=round(((MinSizeY/2)+sin(FlankAng).*FlankDist)-(0.5*TeeImSize))+1;
    target(pY:pY+TeeImSize-1,pX:pX+TeeImSize-1)= target(pY:pY+TeeImSize-1,pX:pX+TeeImSize-1)+subim;
end
if m<MinSizeX
    target=ImClip(target,[n m]);
else
    target=PadIm(target,[n m]);
end
if n<MinSizeY
    target=ImClip(target,[n m]);
else
    target=PadIm(target,[n m]);
end