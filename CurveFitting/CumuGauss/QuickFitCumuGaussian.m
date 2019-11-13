function [uEst,varEst,kpEst,cutEst,fb,err1] = QuickFitCumuGaussian(xvals,propcorr,trialnum,base,maxKP,WhichFitParams,fixVals,cuts,fb)
% QuickFitCumuGaussian
% [uEst,varEst,kpEst,cutEst,fb,err1] = QuickFitCumuGaussian(xvals,propcorr,trialnum,base,maxKP,WhichFitParams,fixVals,cuts,fb)
% returns mean estimate, variance of underlying Gaussian (slope), and keypress error plus fb (ie forwards/backwards function)
% mostly the same as FitCumuGaussian but with fewer iterations (made to use for pre-fitting in the weighted cumu gauss code and elsewhere) and reports back (no cut values)
% used as a pre-fit in FitCumuGaussianWeighted.m as well
%
% new in v1.1 - needed a broader range of potential variance values for curve fits to get decent range of slope/threshold values
%
% eg 1: x=linspace(-5,5,17); prob=([7 6 7 9 7 13 23 17 20 22 34 37 39 44 41 49 48])./50; [u,v,kp,cuts,fb] = QuickFitCumuGaussian(x,prob,50,0,0.05,[1 1 1],[],[0.25 0.5 0.75],1); xfine=linspace(-5,5,1000); probfit=DrawCumuGaussian(xfine,u,v,kp,0,fb); plot(x,prob,'ro',xfine,probfit,'b-');
% eg 2: x=linspace(-5,5,25); prob=(fliplr([50 51 50 48 50 50 51 50 57 63 73 67 70 72 84 87 89 94 91 99 98 99 97 99 97])./100); [u,v,kp,cuts,fb] = QuickFitCumuGaussian(x,prob,100,0.5,0.05,[1 1 1],[],[0.5 0.75],-1); xfine=linspace(-5,5,1000); probfit=DrawCumuGaussian(xfine,u,v,kp,0.5,fb); plot(x,prob,'ro',xfine,probfit,'b-');
%
% John Greenwood, v1.1 July 2019

if ~exist('WhichFitParams')
    WhichFitParams=[1 1 0];
end
if ~exist('fb','var')
    if numel(propcorr)>3
        if mean(propcorr(1:3))>mean(propcorr(end-2:end)) %then have descending function
            fb = -1; %backwards psychometric function
        else %ascending
            fb = 1;
        end
    else %you shouldn't really be fitting this with less than 3 data points but here we go
        if propcorr(1)>propcorr(end) %then have descending function
            fb = -1; %backwards psychometric function
        else %ascending
            fb = 1;
        end
    end
end
if length(trialnum)<length(xvals)
    trialnum=0.*xvals+trialnum(1); %if only input one n value, gets padded out to match all x points
end

opt = optimset(optimset,'MaxFunEvals',50, 'MaxIter',50,'Display','off'); %fewer iterations to get a quick fit

%do a pre-fit to get guess parameters
%add padding to help guess fit
plusmin = round(min(xvals)-(0.5*range(xvals)));%round(xvals(1)-(2*abs(xvals(2)-xvals(1))));%min(xvals)-(range(xvals));
plusmax = round(max(xvals)+(0.5*range(xvals)));%round(xvals(end)+(2*abs(xvals(end)-xvals(end-1))));%max(xvals)+(range(xvals));%values added to pre-fitting to ensure full range (without influencing later fitting)
xtemp = [plusmin xvals plusmax];
if fb==1 %ascending
    ytemp=[base propcorr 1].*max(trialnum(:)); %NB probit needs input as number of responses correct (not propcorr)
else %descending
    ytemp=[1 propcorr base].*max(trialnum(:));
end
numT=ones(1,numel(ytemp)).*max(trialnum(:));%[max(trialnum(:)) trialnum max(trialnum(:))];
[anal_sd,~,anal_ed50,~]=Probit(xtemp,ytemp,numT); %do a pre-fit of 0-1 scaled data
if maxKP==0
    guessKP = 0;
else
    guessKP = 1-max(propcorr);
end

%set up guess vs. fixed parameters
guess1    = [anal_ed50 abs(anal_sd) guessKP]; % 0.01];fitP(find(WhichFitParams)); % Initial guess for the parmeters to be fit
%disp(strcat('guess1:',num2str(guess1)));
fixValsIn = NaN(1,3); %put into the same format as the guess parameters
if exist('fixVals','var') %if there are fixed parameters to input
    guess1(find(~WhichFitParams))    = fixVals; % If user gave us some fixed params slot them into fixVals
    fixValsIn(find(~WhichFitParams)) = fixVals;
end
%set min/max vals for params
fitscale       = 0.001;
rangeVals(1,:) = [min(xvals)-round(0.5*range(xvals)) max(xvals)+round(0.5*range(xvals))]; %min/max for u (min max of xfine range)
rangeVals(2,:) = [fitscale range(xvals)*12]; %min/max for var (min = resolution of xfine done later for cuts, max = range of x-axis)
rangeVals(3,:) = [0 maxKP]; %min/max for KP errors

%do the fitting
[outpt,err1] = fminsearch(@cgFitFun,guess1,opt,xvals,propcorr,base,rangeVals,WhichFitParams,fixValsIn,fb);
%get the final parameters
finalParams=NaN(1,3);%fitP;
finalParams(find(WhichFitParams))  = outpt(find(WhichFitParams)); %fitted parameters
finalParams(find(~WhichFitParams)) = fixVals; %fixed values
uEst   = MaxMin(finalParams(1),rangeVals(1,1),rangeVals(1,2));
varEst = abs(MaxMin(finalParams(2),rangeVals(2,1),rangeVals(2,2))); %positive variance only, and only within range
kpEst  = abs(MaxMin(finalParams(3),rangeVals(3,1),rangeVals(3,2))); %positive KP vals only, and only within range

cutEst=NaN; %save time by not determining cuts

% fitting function is down here:
function err1=cgFitFun(p,levels,data,base,rangeVals,FitParams,fixVals,fb)

defParams=NaN(1,3); %get the array ready
defParams(find(FitParams))=p(find(FitParams)); %fill in the guess parameters
defParams(find(~FitParams))=fixVals(find(~FitParams)); %fill in the fixed values that are not to be fit
%make sure parameters are in range
defParams(1) = MaxMin(defParams(1),rangeVals(1,1),rangeVals(1,2));
defParams(2) = abs(MaxMin(defParams(2),rangeVals(2,1),rangeVals(2,2))); %positive variance only, and only within range
defParams(3) = abs(MaxMin(defParams(3),rangeVals(3,1),rangeVals(3,2))); %positive KP vals only, and only within range
%disp(strcat('defParams:',num2str(defParams)));
%draw a function and determine the error 
prob=DrawCumuGaussian(levels,defParams(1),defParams(2),defParams(3),base,fb);%NormalCumulativeKP(defParams,levels);

err1=sum((prob-data).^2);
