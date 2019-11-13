function [d,c]=dPrime(propHits, propFAs)
%calculates d' = z(hitrate) - z(falsealarms)
%and criterion C = -(z(hitrate) + z(falsealarms))/2
%for criterion: -ve values = high 'yes/different', +ve values = high 'no/same'
%need to input proportion of hits and proportion of false alarms
%e.g. [d,c] = dPrime(0.74,0.01)
%John Greenwood 2011

HighVals = find(propHits==1); %find any unusable max or min values and correct
LowVals  = find(propHits==0);
HighFAs  = find(propFAs==1);
LowFAs   = find(propFAs==0);
if LowVals
    propHits(LowVals)=0.001;
end
if propHits(HighVals)
    propHits(HighVals)=0.999;
end
if propFAs(LowFAs)==0
    propFAs(LowFAs)=0.001;
end
if propFAs(HighFAs)==1
    propFAs(HighFAs)=0.999;
end

if propHits~=0 & propHits~=1 & propFAs~=0 & propFAs~=1 %The d' calculation can be made since all values are between 0 and 1
    mean = 0; %Mean of the gaussian distribution on which the calc is made
    stDev = 1; %StDeviation of the gaussian distribution on which the calc is made.
    zHits = norminv(propHits, mean, stDev);
    zFalseAlarms = norminv(propFAs, mean, stDev);
    d = zHits - zFalseAlarms; %calculate d prime
    c = -(zHits + zFalseAlarms)./2; %calculate criterion
else
    d=-99; %The d' calculation cannot be made since at least one value is 0 or 1
    c=-99; %likewise c
end
