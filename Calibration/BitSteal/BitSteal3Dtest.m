% BitSteal3Dtest
%bitstealing test code for the viewsonic/samsung stereo monitors
% J Greenwood 2010 modified from code by Steven Dakin

im=DoLog(rand(228),8);
load('C:\Documents\MATLAB\Calibration\CalDataAsusVG278right3DBitSteal.mat');%load('C:\Users\JohnG\Matlab Files\Calibration\BitStealCal3D.mat');
NoBits=8;
noEntries=(2^NoBits-1)*7;
fineVoltages=linspace(0,noEntries-1,noEntries);
PedVals=floor(fineVoltages./7);

Offsets=mod(fineVoltages,7);
MostSB=floor(Offsets./4);
MidSB=floor((Offsets-4.*MostSB)./2);
LowSB=floor((Offsets-4.*MostSB-2.*MidSB));
 
vLUT=zeros(noEntries,3);
vLUT(:,1)=PedVals+MidSB;
vLUT(:,2)=PedVals+MostSB;
vLUT(:,3)=PedVals+LowSB;
vLUT(noEntries+1,:)=[2^NoBits-1 2^NoBits-1 2^NoBits-1];
displayableL=LR.VtoLfunR(LR,vLUT(:,1)')+LR.VtoLfunG(LR,vLUT(:,2)')+LR.VtoLfunB(LR,vLUT(:,3)');
plot(displayableL,'o')
[m n]=size(im);
im=15+10.*NormImage(im,0,1);
rgbIm=repmat(im,[1 1 3]);
for i=1:m
    for j=1:n
        [minVal minInd]=min(abs(im(i,j)-displayableL));
        rgbIm(i,j,:)=vLUT(minInd,:);
    end
end
figure
ishow(rgbIm)
