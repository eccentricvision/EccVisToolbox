%DotMovementDemo
%simple script to look at movement of dots

clear all;
sp.DotNum = 1000;
sp.ApRadPix = 500;
sp.IsolationRad = 3;
sp.StimWaitFrames = 5;
sp.DotPixPerStep  = 5;
MeanDir  = 90;
DelTheta = 40;

[dotsXY(:,:,1)] = PlotDotsFirstFrame(sp.DotNum,sp.ApRadPix-2); %generate first position for dots as ±max apRad
[dotsXY(:,:,1),dotsmoved,func_exit,numdotexit] = CheckDotOverlap(dotsXY(:,:,1),sp.IsolationRad,sp.ApRadPix); %check for any overlaps and shift dots if necessary (quits if no space)

DotDirs = linspace(MeanDir-(DelTheta/2),MeanDir+(DelTheta/2),sp.DotNum);%MeanDir+[ones(1,round(sp.DotNum/2)).*DirVals(1) ones(1,round(sp.DotNum/2)).*DirVals(2)]
for frm=1:sp.StimWaitFrames
    if frm>1 %then need to displace dots
            DorDirs(DotDirs<0)   = DotDirs(DotDirs<0)+360; %wrap to 0-360 values
            DotDirs(DotDirs>359) = DotDirs(DotDirs>359)-360;
            %displace the dots and wrap if needed
            [dotsXY(:,:,frm),dotswrapped,func_exit,numdotexit] = dotDisplaceWithWrap(dotsXY(:,:,frm-1),DotDirs,sp.DotPixPerStep,sp.IsolationRad,sp.ApRadPix);
    end
end

figure
for dd=1:sp.DotNum
plot(squeeze(dotsXY(dd,1,:)),squeeze(dotsXY(dd,2,:)),'o');
hold on;
end
axis square;