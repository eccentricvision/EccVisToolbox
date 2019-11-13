function [bestParams,cutvals,err1] = FitWeibull(inputs,resps,WhichFitParams,cuts)
% FitWeibull
%  [bestParams,cutvals,err1] = FitWeibull(inputs,resps,WhichFitParams,cuts)
% returns three parameters: k, lambda, and ±1 to give direction
% cuts are proportion values to take, cutvals are returned 
% then use DrawWeibull to generate a curve for plotting using these parameters
%
% eg1: x=linspace(10,20,17); prob=([7 6 7 9 7 13 23 17 20 22 34 37 39 44 41 49 48])./50; [bestParams,cutvals] = FitWeibull(x,prob,[1 1],[0.25 0.5 0.75]); xfine=linspace(min(x),max(x),1000); probfit=DrawWeibull(xfine,bestParams); plot(x,prob,'ro',xfine,probfit,'b-');
% eg2: x = fliplr(7.6-[1.6 2 2.8 4.4 6 7.6]); prob = fliplr([0.97 1 0.34 0 0.06 0.02]);[bestParams,cutvals] = FitWeibull(x,prob,[1 1],[0.25 0.5 0.75]); xfine=linspace(min(x),max(x),1000); probfit=DrawWeibull(xfine,bestParams); plot(x,prob,'ro',xfine,probfit,'b-');
% modified J Greenwood 2011

if ~exist('WhichFitParams')
   WhichFitParams=[1 1];
end

opt = optimset(optimset,'MaxFunEvals',5000, 'MaxIter',5000); %opt = optimset(optimset,'MaxFunEvals',1000);
if resps(1)>resps(end) %then have descending function
    fb = -1; %backwards psychometric function
else %ascending
    fb = 1;
end

%guess midpoint
midval = max(resps)/2;%mean(resps-min(resps))+min(resps);
vals=abs(resps-midval); %find the point where curve gets closest to desired cut point
temp = inputs(find(vals==min(min(vals)))); %take minimum of function
if numel(temp)>1
    guessParams(1) = temp(round(length(temp)/2)); %take middle element
else
    guessParams(1) = temp;
end
%guessParams(1) = median(inputs); %guess midpoint at middle of range
guessParams(2) = 3; %guess exponent at 3 - nice curve

[x,err1] = fminsearch(@cgFitFun,guessParams(find(WhichFitParams)),opt,inputs,resps,WhichFitParams,fb);
finalParams=[1 1];
finalParams(find(WhichFitParams))=x;
bestParams(1)  = finalParams(1);
bestParams(2)  = finalParams(2);%abs(finalParams(2));
bestParams(3)  = fb;

xfine = min(inputs):0.0001:max(inputs);
prob = DrawWeibull(xfine,bestParams); %run curve fit to extract cut values for midpoint, threshold etc
for cc=1:length(cuts)
    vals=abs(prob-cuts(cc)); %find the point where curve gets closest to desired cut point
    temp = xfine(find(vals==min(min(vals)))); %take minimum of function
    if numel(temp)>1
        cutEst(cc) = temp(round(length(temp)/2)); %take middle element 
    else
        cutEst(cc) = temp;
    end
end
cutvals = cutEst;

function err1=cgFitFun(p,levels,data,FitParams,fb)
p(1) = (p(1));
%p(2) = abs(p(2));

defParams=[1 1];
defParams(find(FitParams))=p;
prob=DrawWeibull(levels,[defParams fb]);%NormalCumulativeKP(defParams,levels);
err1=sum((prob-data).^2);


