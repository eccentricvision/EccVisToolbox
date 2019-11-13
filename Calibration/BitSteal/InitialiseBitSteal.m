%InitialiseBitSteal
%code to setup a lookup table for bit stealing
%then use bitstealval to get the precise vals
% Originally S Dakin 2010 (for BitStealVal)
% modified J Greenwood 2014 for quicker image bitstealing

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

displayableL=LR.VtoLfunR(LR,vLUT(:,1)')+LR.VtoLfunG(LR,vLUT(:,2)')+LR.VtoLfunB(LR,vLUT(:,3)'); %possible luminance values
numLum   = numel(displayableL); %number of possible luminance values

LinearLum = linspace(min(displayableL(:)),max(displayableL(:)),numLum); %linearised luminance values from min to max

for lum=1:numLum
[minVal(lum),LinearInd(lum)] = min(abs(LinearLum(lum)-displayableL)); %find the closest displayableL for each desired luminance level (linearised)

%ImInd = find(imValLum==uniqueVals(uu)); %indices for the current contrast level
end

%add some extra things to LR (easiest way to transport it all into BitStealVal etc

LR.Lmax = max(displayableL(:));
LR.Lmin = min(displayableL(:));
LR.LinearLum = LinearLum; %values of the linear luminance values
LR.LinearInd = LinearInd; %indices for the linearised look-up table

