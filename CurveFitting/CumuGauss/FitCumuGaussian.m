function [uEst,varEst,kpEst,cutEst,fb,err1] = FitCumuGaussian(xvals,propcorr,trialnum,base,maxKP,WhichFitParams,fixVals,cuts,fb)
% FitCumuGaussian
% [uEst,varEst,kpEst,cutEst,fb,err1] = FitCumuGaussian(xvals,propcorr,trialnum,base,maxKP,WhichFitParams,fixVals,cuts,fb)
% returns mean estimate, variance of underlying Gaussian (slope), and keypress error plus fb (ie forwards/backwards function)
% then use DrawCumuGaussian to generate a curve for plotting using these parameters
% see FitCumuGaussDemo.m for step-by-step instructions
%
% xvals=x axis, trialnum=n trials per point, propcorr=y axis (as proportion), whichFitParams? [1 1 1]; fixVals = any fixed values (where whichFitParams=0) to input, or [] if none 
% cuts = prop. correct to find x-axis val for; fb=forwards=1/backwards-1;
% base = prop. correct as baseline of function (eg 0.5 for 2AFC); maxKP = maximum keypress error value (~0.05 typically)
% need to enter data as proportion correct (0-1), then with trials per point the %s are calculated
% if input an fb value it will be fixed, otherwise will determine this
% new in v3.1 - some minor alterations to make code run more quickly (less precision in cut-finding to end) and bring in line with FitCumuGaussianWeighted
% new in v3.2 - needed a broader range of potential variance values for curve fits to get decent range of slope/threshold values
%
% eg 1: x=linspace(-5,5,17); prob=([7 6 7 9 7 13 23 17 20 22 34 37 39 44 41 49 48])./50; [u,v,kp,cuts,fb] = FitCumuGaussian(x,prob,50,0,0.05,[1 1 1],[],[0.25 0.5 0.75],1); xfine=linspace(-5,5,1000); probfit=DrawCumuGaussian(xfine,u,v,kp,0,fb); plot(x,prob,'ro',xfine,probfit,'b-');
% eg 2: x=linspace(-5,5,25); prob=(fliplr([50 51 50 48 50 50 51 50 57 63 73 67 70 72 84 87 89 94 91 99 98 99 97 99 97])./100); [u,v,kp,cuts,fb] = FitCumuGaussian(x,prob,100,0.5,0.05,[1 1 1],[],[0.5 0.75],-1); xfine=linspace(-5,5,1000); probfit=DrawCumuGaussian(xfine,u,v,kp,0.5,fb); plot(x,prob,'ro',xfine,probfit,'b-');
%
% John Greenwood, v3.2 July 2019

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

opt = optimset(optimset,'MaxFunEvals',10000, 'MaxIter',10000); %opt = optimset(optimset,'MaxFunEvals',1000);

%do a pre-fit to get guess parameters
if ((range(propcorr([1 2 end-1 end]))/(1-base))<(1/4))%abs(range(propcorr([1 2 end-1 end]))-(1-base))>0.1 %then range of values isn't particularly broad, add some padding to help initial guess fit
    plusmin = round(min(xvals)-(0.5*range(xvals)));%round(xvals(1)-(2*abs(xvals(2)-xvals(1))));%min(xvals)-(range(xvals));
    plusmax = round(max(xvals)+(0.5*range(xvals)));%round(xvals(end)+(2*abs(xvals(end)-xvals(end-1))));%max(xvals)+(range(xvals));%values added to pre-fitting to ensure full range (without influencing later fitting)
    xtemp   = [plusmin xvals plusmax];
    if fb==1 %ascending
        ytemp=[base propcorr 1].*trialnum(1);
    else %descending
        ytemp=[1 propcorr base].*trialnum(1);
    end
    numT=[mean(trialnum(:)) trialnum mean(trialnum(:))];
else %range of values is sufficient to likely get a good curve fit = just estimate parameters based on this data
    xtemp = xvals;
    ytemp = propcorr.*trialnum(1);
    numT  = trialnum;
end
[anal_sd,~,anal_ed50,~]=Probit(xtemp,ytemp,numT); %do a pre-fit of 0-1 scaled data
if maxKP==0
    guessKP = 0;
else
    guessKP = 1-max(propcorr);
end

%set up guess vs. fixed parameters
guess1    = [anal_ed50 abs(anal_sd) guessKP]; % 0.01];fitP(find(WhichFitParams)); % Initial guess for the parmeters to be fit
fixValsIn = NaN(1,3); %put into the same format as the guess parameters
if exist('fixVals','var') %if there are fixed parameters to input
    guess1(find(~WhichFitParams))    = fixVals; % If user gave us some fixed params slot them into fixVals
    fixValsIn(find(~WhichFitParams)) = fixVals;
end
%set min/max vals for params
fitscale       = 0.001;
rangeVals(1,:) = [min(xvals)-round(0.5*range(xvals)) max(xvals)+round(0.5*range(xvals))]; %min/max for u (min max of xfine range)
rangeVals(2,:) = [fitscale range(xvals)*24]; %min/max for var (min = resolution of xfine done later for cuts, max = range of x-axis)
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

%fit a function to get the cut values
xfine = min(xvals)-round(0.5*range(xvals)):fitscale:max(xvals)+round(0.5*range(xvals));%xfine = min(xvals):0.0001:max(xvals);xfine = min(xvals):0.0001:max(xvals);
prob  = DrawCumuGaussian(xfine,uEst,varEst,kpEst,base,fb); %run curve fit to extract cut values for midpoint, threshold etc
for cc=1:length(cuts)
    if min(prob)>cuts(cc)
        cutEst(cc) = min(xfine);%min(xvals);
        %disp('cut value below range');
    elseif max(prob)<cuts(cc)
        cutEst(cc) = max(xfine);%max(xvals);
        %disp('cut value above range');
    else %find the appropriate cutpoint 
    vals=abs(prob-cuts(cc)); %find the point where curve gets closest to desired cut point
    temp = xfine(vals==min(vals(:))); %take minimum of function
        if numel(temp)>1
            if numel(temp)>100 %too many values (likely a flat or overly steep function) - safer to return a NaN
                cutEst(cc) = NaN;
                %disp('Warning (FitCumuGaussianWeighted): too many cuts!');
            else
                cutEst(cc) = temp(round(length(temp)/2)); %take middle element
            end
        elseif isempty(temp)
            cutEst(cc) = NaN; %no appropriate value
            %disp('Warning (FitCumuGaussianWeighted): no cut!');
        else
            cutEst(cc) = temp;
        end
    end
end

% fitting function is down here:
function err1=cgFitFun(p,levels,data,base,rangeVals,FitParams,fixVals,fb)

defParams=NaN(1,3); %get the array ready
defParams(find(FitParams))=p(find(FitParams)); %fill in the guess parameters
defParams(find(~FitParams))=fixVals(find(~FitParams)); %fill in the fixed values that are not to be fit
%make sure parameters are in range
defParams(1) = MaxMin(defParams(1),rangeVals(1,1),rangeVals(1,2));
defParams(2) = abs(MaxMin(defParams(2),rangeVals(2,1),rangeVals(2,2))); %positive variance only, and only within range
defParams(3) = abs(MaxMin(defParams(3),rangeVals(3,1),rangeVals(3,2))); %positive KP vals only, and only within range

%draw a function and determine the error
prob=DrawCumuGaussian(levels,defParams(1),defParams(2),defParams(3),base,fb);%NormalCumulativeKP(defParams,levels);
err1=sum((prob-data).^2);


