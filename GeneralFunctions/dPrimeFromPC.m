function d=dPrimeFromPC(propCorrect,numAlt)
% calculates d' from percent correct data (propCorrect) for nAFC data (numAlt)
% using the equation d' = (z(PC) -z(1/n))./An
%need to input proportion correct and number of alternatives
%e.g. d = dPrimeFromPC(0.74,4)
%John Greenwood 2010

HighVals = find(propCorrect==1); %find any unusable max or min values and correct
LowVals  = find(propCorrect==0);
if LowVals
    propCorrect(LowVals)=0.001;
end
if propCorrect(HighVals)
    propCorrect(HighVals)=0.999;
end

if propCorrect~=0 & propCorrect~=1 & propCorrect~=0 & propCorrect~=1 %The d' calculation can be made since all values are between 0 and 1
    mean = 0; %Mean of the gaussian distribution on which the calc is made
    stDev = 1; %StDeviation of the gaussian distribution on which the calc is made.
    zPC = norminv(propCorrect, mean, stDev); %z score for percent correct
    zAlt = norminv(1/numAlt, mean, stDev);  %z score for chance
    An = GenAn(numAlt);
    d = (zPC - zAlt)./An;
else
    d=-99; %The d' calculation cannot be made since at least one value is 0 or 1
end

end
%%
function An = GenAn(numAlt)
%generate An value using equations from James R. Alexander
An = 1-1./(1.93+4.75*log10(numAlt)+0.63*sqrt(log10(numAlt)));
end
