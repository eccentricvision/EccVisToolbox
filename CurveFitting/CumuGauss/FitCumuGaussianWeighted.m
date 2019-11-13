function [uEst,varEst,kpEst,cutEst,fb] = FitCumuGaussianWeighted(xvals,propcorr,trialnum,base,maxKP,WhichFitParams,fixVals,cuts,fb,SmFit)
% FitCumuGaussianWeighted
% [uEst,varEst,kpEst,cutEst,fb] = FitCumuGaussianWeighted(xvals,propcorr,trialnum,base,maxKP,WhichFitParams,fixVals,cuts,fb,SmFit)
% returns mean estimate, variance of underlying Gaussian (slope), and keypress error plus fb (ie forwards/backwards function)
% then use DrawCumuGaussian to generate a curve for plotting using these parameters
% see FitCumuGaussWeightedDemo.m for step-by-step instructions
% error term in the fits is weighted by how many trials there are per point
% new in v4.0 - uses a smoothed fit to get guess parameters first before doing the fitting
% new in v4.2 - added finer cut estimation
% new in v4.3 - much improved pre-fitting, faster running, some error fixes and clean up
% new in v5.1 - combined binning/smoothing pre-fits and then take the best for the smooth fitting (combines v4.3 and v5.0), plus constrained ranges for parameters
% new in v5.2 - needed a broader range of potential variance values for curve fits to get decent range of slope/threshold values
%
% xvals=x axis, trialnum=n trials per point, propcorr=y axis (as proportion), whichFitParams? [1 1 1]; fixVals = any fixed values (where whichFitParams=0) to input, or [] if none
% cuts = prop. correct to find x-axis val for; fb=forwards=1/backwards-1;
% need to enter data as proportion correct, then with trials per point the %s are calculated
% if input an fb value it will be fixed, otherwise will determine this
% eg 1: x=linspace(-5,5,17); prob=([7 6 7 9 7 13 23 17 20 22 34 37 39 44 41 49 48])./50; [u,v,kp,cuts,fb] = FitCumuGaussianWeighted_TestFit(x,prob,50,0,0.05,[1 1 1],[],[0.25 0.5 0.75],1,1); xfine=linspace(-5,5,1000); probfit=DrawCumuGaussian(xfine,u,v,kp,0,fb); plot(x,prob,'ro',xfine,probfit,'b-');
% eg 2: x=linspace(-5,5,25); prob=(fliplr([50 51 50 48 50 50 51 50 57 63 73 67 70 72 84 87 89 94 91 99 98 99 97 99 97])./100); [u,v,kp,cuts,fb] = FitCumuGaussianWeighted_TestFit(x,prob,100,0.5,0.05,[1 1 1],[],[0.5 0.75],-1,1); xfine=linspace(-5,5,1000); probfit=DrawCumuGaussian(xfine,u,v,kp,0.5,fb); plot(x,prob,'ro',xfine,probfit,'b-');
%
% John Greenwood v5.2 July 2019

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
    else
        if propcorr(1)>propcorr(end) %then have descending function
            fb = -1; %backwards psychometric function
        else %ascending
            fb = 1;
        end
    end
end
if ~exist('SmFit'); %no input for whether to use the new smoothed pre-fitting or not
    SmFit = 1;
end

if length(trialnum)<length(xvals)
    trialnum=0.*xvals+trialnum(1); %if only input one n value, gets padded out to match all x points
end

opt = optimset(optimset,'MaxFunEvals',1000, 'MaxIter',1000); %opt = optimset(optimset,'MaxFunEvals',1000);

%do a pre-fit to get guess parameters
if ((range(propcorr([1 2 end-1 end]))/(1-base))<(1/4)) || numel(propcorr<4) %range of values isn't so broad (less than 1/4 of range) = add padding to help guess fit (or if low num of datapoints)
    plusmin = round(min(xvals)-(0.5*range(xvals)));%round(xvals(1)-(2*abs(xvals(2)-xvals(1))));%min(xvals)-(range(xvals));
    plusmax = round(max(xvals)+(0.5*range(xvals)));%round(xvals(end)+(2*abs(xvals(end)-xvals(end-1))));%max(xvals)+(range(xvals));%values added to pre-fitting to ensure full range (without influencing later fitting)
    xtemp = [plusmin xvals plusmax];
    numT=[mean(trialnum(:)) trialnum mean(trialnum(:))];
    if fb==1 %ascending
        ytemp=[base propcorr 1];
    else %descending
        ytemp=[1 propcorr base];
    end
    %disp('range adjusted');
else %range of values is sufficient to likely get a good curve fit = just estimate parameters based on this data
    xtemp = xvals;
    ytemp = propcorr;
    numT  = trialnum;
end
if SmFit
    fitcnt=1; %pre-fit counter
    fittype={};
    %do some smooth fits
    smvals = [1 3 5 7]; %9] %different levels of smoothing (where 1=unsmoothed)
    smvals = smvals(smvals<numel(ytemp)); %filter out any smoothing levels that exceed number of data points
    for sm=1:numel(smvals)
        if numel(ytemp)>smvals(sm) %x-point smoothing - %do a fit of a regular gaussian to smoothed data to get a sense of the pattern
            bc = 1/smvals(sm).*ones(1,smvals(sm)); %e.g. [1/3 1/3 1/3] - the boxcar to take the running average
            SmoothProp = conv(ytemp,bc,'same');
            xsmooth    = xtemp(1+(smvals(sm)-round(smvals(sm)/2)):end-(smvals(sm)-round(smvals(sm)/2)));
            ysmooth    = SmoothProp(1+(smvals(sm)-round(smvals(sm)/2)):end-(smvals(sm)-round(smvals(sm)/2)));
            
            [anal_ed50(fitcnt),anal_sd(fitcnt),kpGuess(fitcnt),~,~,~] = QuickFitCumuGaussian(xsmooth,ysmooth,mean(trialnum(:)),base,maxKP,WhichFitParams,fixVals,NaN,fb);
            
            weights = numT./sum(numT);
            fitdata  = DrawCumuGaussian(xtemp,anal_ed50(fitcnt),anal_sd(fitcnt),kpGuess(fitcnt),base,fb);
            err2(fitcnt) = sum(((ytemp-fitdata).^2).*weights);%sum((propcorr-fitdata).^2);
            %fittype = horzcat(fittype,strcat('Smoothed-',num2str(smvals(sm))));%used for reporting pre-fit outcomes (if used)
            fitcnt=fitcnt+1;
        end
    end
    %now do some binned fits
    numbin = [4 9 11 13];% numel(propcorr)]; %[7 %take bins of varying numbers for the pre-fit, including no/minimal binning
    numbin = numbin(numbin<=numel(propcorr)); %filter out any smoothing levels that exceed number of data points
    
    for bb=1:numel(numbin)
        [binInd,edges] = discretize(xtemp,numbin(bb)); %divides range into bins of equal width
        for bin=1:(numel(edges)-1)
            xBin{bb}(bin) = mean([edges(bin) edges(bin+1)]); %take midpoint of each bin as the relevant x value         %xBin{bb} = edges(1:end-1); %take the left edge of each bin as the relevant x value
        end
        for binval = 1:numel(xBin{bb})
            PropCorrBin{bb}(binval)  = sum(ytemp(binInd==binval))./numel(ytemp(binInd==binval)); %average the respcorr in each bin
            NumTrialsBin{bb}(binval) = numel(numT(binInd==binval)); %sum the numtrials in each bin
        end
        %remove any NaNs where there are no trials within a given bin
        nanfinder        = isnan(PropCorrBin{bb});
        xBin{bb}         = xBin{bb}(~nanfinder);
        PropCorrBin{bb}  = PropCorrBin{bb}(~nanfinder);
        NumTrialsBin{bb} = NumTrialsBin{bb}(~nanfinder);
        %do the pre-fit using QuickFitCumuGauss
        [anal_ed50(fitcnt),anal_sd(fitcnt),kpGuess(fitcnt),~,~] = QuickFitCumuGaussian(xBin{bb},PropCorrBin{bb},mean(NumTrialsBin{bb}),base,maxKP,WhichFitParams,fixVals,NaN,fb);
        
        %calculate weighted error from actual data
        fitdata          = DrawCumuGaussian(xtemp,anal_ed50(fitcnt),anal_sd(fitcnt),kpGuess(fitcnt),base,fb);
        weights          = numT./sum(numT); %get the proportion of trialnum for each point as a weight (0-1)
        err2(fitcnt)     = sum(((ytemp-fitdata).^2).*weights); %multiply the error by the weight for each point (determined by the number of trialnum)
        %fittype = horzcat(fittype,strcat('Binned-',num2str(numbin(bb))));%used for reporting pre-fit outcomes (if used)
        fitcnt=fitcnt+1;
    end
else %old-style probit pre-fit
    plusmin = round(xvals(1)-(2*abs(xvals(2)-xvals(1))));%min(xvals)-(range(xvals));
    plusmax = round(xvals(end)+(2*abs(xvals(end)-xvals(end-1))));%max(xvals)+(range(xvals));%values added to pre-fitting to ensure full range (without influencing later fitting)
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
end

[~,bestfit] = min(err2); %find the best of the above fits
anal_ed50 = anal_ed50(bestfit);
anal_sd   = anal_sd(bestfit);
if maxKP==0
    kpGuess = 0;
else
    kpGuess = kpGuess(bestfit);%1-max(propcorr);
end
%disp(strcat('Winner is ',fittype(bestfit))); %report best pre-fit to workspace

%set up guess vs. fixed parameters
guess1    = [anal_ed50 abs(anal_sd) kpGuess]; % 0.01];fitP(find(WhichFitParams)); % Initial guess for the parmeters to be fit
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
[outpt,err1] = fminsearch(@cgFitFun,guess1,opt,xvals,propcorr,trialnum,base,rangeVals,WhichFitParams,fixValsIn,fb);
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
function err1=cgFitFun(p,levels,data,trialnum,base,rangeVals,FitParams,fixVals,fb)

defParams=NaN(1,3); %get the array ready
defParams(find(FitParams))=p(find(FitParams)); %fill in the guess parameters
defParams(find(~FitParams))=fixVals(find(~FitParams)); %fill in the fixed values that are not to be fit
%make sure parameters are in range
defParams(1) = MaxMin(defParams(1),rangeVals(1,1),rangeVals(1,2));
defParams(2) = abs(MaxMin(defParams(2),rangeVals(2,1),rangeVals(2,2))); %positive variance only, and only within range
defParams(3) = abs(MaxMin(defParams(3),rangeVals(3,1),rangeVals(3,2))); %positive KP vals only, and only within range

%draw a function and determine the error
prob=DrawCumuGaussian(levels,defParams(1),defParams(2),defParams(3),base,fb);%NormalCumulativeKP(defParams,levels);

weights = trialnum./sum(trialnum); %get the proportion of trialnum for each point as a weight (0-1)
if max(weights)>0.2  %weighting likely too skewed towards 1-2 data points so apply a softer weighting using square root
    weights = (sqrt(weights)./sum(sqrt(weights))); %apply softer weighting  - or no weighting = ones(size(weights));
end

err1=sum(((prob-data).^2).*weights); %multiply the error by the weight for each point (determined by the number of trialnum)
