function [kEst,midptEst,minvalEst,maxvalEst,err1] = FitLogisticFun(xvals,yvals,WhichFitParams,fixVals)
% FitLogisticFun
% function [kEst,midptEst,minvalEst,maxvalEst,err1] = FitLogisticFun(xvals,yvals,WhichFitParams,fixVals)
% fit a logistic function to the data of the form yvals  = ((maxval-minval)./(1+exp(-k.*(xvals-midpt))))+minval;
% fits 4 free parameters: k (slope), midpt (midpoint of the function), minval (minimum yval), maxval (maximum yval)
% xvals=x axis, yvals = y values, whichFitParams? [1 1 1 1]; fixVals = any fixed values (where whichFitParams=0) to input, or [] if none 
% see FitLogisticDemo.m for an example script for fitting and drawing
%
% eg 1: xvals=linspace(-5,5,17); yvals=([7 6 7 9 7 13 23 17 20 22 34 37 39 44 41 49 48]); [kval,midpt,minval,maxval] = FitLogisticFun(xvals,yvals,[1 1 1 1],[]); xfine=linspace(-5,5,1000); probfit=DrawLogisticFun(xfine,kval,midpt,minval,maxval); plot(xvals,yvals,'ro',xfine,probfit,'b-');
% 
% John Greenwood, v1.0 March 2020 lockdown

if ~exist('WhichFitParams')
    WhichFitParams=[1 1 1 1];
end

opt = optimset(optimset,'MaxFunEvals',10000, 'MaxIter',10000); %opt = optimset(optimset,'MaxFunEvals',1000);

%do a pre-fit to get guess parameters
if numel(yvals)>3
    if mean(yvals(1:3))>mean(yvals(end-2:end)) %then have descending function
        fb = -1; %backwards function
    else %ascending
        fb = 1;
    end
else %you shouldn't really be fitting this with less than 3 data points but here we go
    if yvals(1)>yvals(end) %then have descending function
        fb = -1; %backwards function
    else %ascending
        fb = 1;
    end
end
[anal_sd,~,anal_ed50,~]=Probit(xvals,yvals,ones(1,numel(yvals)).*max(yvals(:))); %do a pre-fit of 0-1 scaled data
kGuess      = (1/abs(anal_sd)).*fb;
midptGuess  = anal_ed50;
minvalGuess = min(yvals(:));
maxvalGuess = max(yvals(:));

%set up guess vs. fixed parameters
guess1    = [kGuess midptGuess minvalGuess maxvalGuess]; % 0.01];fitP(find(WhichFitParams)); % Initial guess for the parmeters to be fit
fixValsIn = NaN(1,4); %put into the same format as the guess parameters
if exist('fixVals','var') %if there are fixed parameters to input
    guess1(find(~WhichFitParams))    = fixVals; % If user gave us some fixed params slot them into fixVals
    fixValsIn(find(~WhichFitParams)) = fixVals;
end

%do the fitting
[outpt,err1] = fminsearch(@cgFitFun,guess1,opt,xvals,yvals,WhichFitParams,fixValsIn);

%get the final parameters
finalParams=NaN(1,4);%fitP;
finalParams(find(WhichFitParams))  = outpt(find(WhichFitParams)); %fitted parameters
finalParams(find(~WhichFitParams)) = fixVals; %fixed values
kEst      = finalParams(1);
midptEst  = finalParams(2);
minvalEst = finalParams(3);
maxvalEst = finalParams(4);

% fitting function is down here:
function err1=cgFitFun(p,levels,data,FitParams,fixVals)

defParams=NaN(1,4); %get the array ready
defParams(find(FitParams))=p(find(FitParams)); %fill in the guess parameters
defParams(find(~FitParams))=fixVals(find(~FitParams)); %fill in the fixed values that are not to be fit
%make sure parameters are in range
%defParams(1) = MaxMin(defParams(1),rangeVals(1,1),rangeVals(1,2));
%defParams(2) = abs(MaxMin(defParams(2),rangeVals(2,1),rangeVals(2,2))); %positive variance only, and only within range
%defParams(3) = abs(MaxMin(defParams(3),rangeVals(3,1),rangeVals(3,2))); %positive KP vals only, and only within range

%draw a function and determine the error
prob=DrawLogisticFun(levels,defParams(1),defParams(2),defParams(3),defParams(4));%NormalCumulativeKP(defParams,levels);
err1=sum((prob-data).^2);


