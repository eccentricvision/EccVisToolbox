function [u1Est,u2Est,varEst,scale1Est,scale2Est,offsetEst,err1] = FitBimodalGaussian(xvals,prop,minparams,maxparams)
% [u1Est,u2Est,varEst,scale1Est,scale2Est,offsetEst,err1] = FitBimodalGaussian(xvals,prop,minparams,maxparams)
%
% Fits a bimodal Gaussian function to the passed data.
% Uses lsqcurvefit with six parameters: means 1&2 (i.e. peak locations), variance, scales 1&2 (peak-to-base height), offset (base height)
% also returns the residual error of the fit to the data (for each x-axis position)
%
% If you use the form 'FitBimodalGaussian(xvals,prop)' you'll get the usual
% 6-parameter fit (mean1,mean2,variance,scale1,scale2,offset)
%
% With minparams and maxparams you can constrain the range of each of the 6 parameters (in order of entry above)
% Default is minparams = [-Inf -Inf 0 -Inf -Inf -Inf], maxparams = [Inf Inf Inf Inf Inf Inf];
% where Inf values are unconstrained (so only variance is constrained to have positive values)
% If you want to restrict parameters to a range then this can be done. If you want a fixed value,
% you can't enter the same value for min and max but can enter an arbitrarily small range e.g. -0.01 to 0.01
%
%
% eg. x=[-60:15:60];prop=[0 0.2 0.4 0.1 0.3 0.6 0.2 0 0];[u1E,u2E,vE,s1E,s2E,oE,lseBM]=FitBimodalGaussian(x,prop,[-Inf -Inf 0 -Inf -Inf -Inf],[Inf Inf Inf Inf Inf Inf]);xFine=[-60:0.1:60];prop2=DrawBimodalGaussian(xFine,u1E,u2E,vE,s1E,s2E,oE);plot(x,prop,'o',xFine,prop2,'-');
%
% J Greenwood 2015

guessprop = prop./max(prop(:)); %make sure data is converted to proportions for guess parameters

% Set up an initial guess for the first curve parameters
mean1Guess       = xvals(find(prop==max(prop)));%sum(xvals.*guessprop)/(sum(guessprop));
if numel(mean1Guess)>1
   mean1Guess = median(mean1Guess);  
end
offsetGuess     = min(prop);
if mean1Guess>xvals(round(numel(xvals)/2)) %RHS curve
    halfxvals     = xvals(round(numel(xvals)/2):numel(xvals)); %half the xvals-axis for guess variance of one lobe
    halfgprop = guessprop(round(numel(xvals)/2):numel(xvals)); %half the input data to compute guess variance
else %LHS curve
    halfxvals     = xvals(1:round(numel(xvals)/2)); %half the x-axis for guess variance of one lobe
    halfgprop = guessprop(1:round(numel(xvals)/2)); %half the input data to compute guess variance
end
varGuess        = abs(var((guessprop-min(guessprop)).*(xvals-mean1Guess)))./4;%abs(var((guessprop-min(guessprop)).*(guessprop-mean1Guess)));%abs(var((halfgprop-min(halfgprop)).*(halfxvals-mean1Guess)))./2; %works best if divide estimate by 2
scale1Guess     = max(prop)-mean(prop([1 end])); %max(prop)-mean(prop([1 2 end-1 end]));

%now fit a unimodal gaussian function (using the half parameters above) and subtract that from the full data
OneSideGuess = DrawGaussian(xvals,mean1Guess,varGuess,scale1Guess,offsetGuess);
OneSideGuess(isnan(OneSideGuess))=scale1Guess; %make sure there aren't any NaN values (due to odd fits)
propdiff     = prop - OneSideGuess; %subtract off the guess for the other side of the Gaussian

%now compute the guess parameters for the other curve guess
mean2Guess   = xvals(find(propdiff==max(propdiff)));%sum(xvals.*guessprop)/(sum(guessprop));
if mean1Guess>xvals(round(numel(xvals)/2)) %RHS curve
    mean2Guess   = mean2Guess(1); %make sure only one value is returned (on the LHS ideally)
else
    mean2Guess = mean2Guess(end);
end
scale2Guess = max(propdiff)-mean(propdiff([1 end])); %scale2Guess = max(propdiff)-mean(propdiff([1 2 end-1 end]));

guessParams=[mean1Guess mean2Guess varGuess scale1Guess scale2Guess offsetGuess]; % Default parameters for fit

if ~exist('minparams')
    minparams = [-Inf -Inf 0 -Inf -Inf -Inf]; %default is just to make sure variance isn't negative
end
if ~exist('maxparams')
    maxparams = [Inf Inf Inf Inf Inf Inf]; %default is no upper bounds
end

opt = optimset(optimset,'MaxFunEvals',1000,'Display','off'); %options for the fit

% Actually do the fit
[estParams,~,err1] = lsqcurvefit(@gFitFun,guessParams,xvals,prop,minparams,maxparams,opt);

% Return all the parameters
u1Est=estParams(1);
u2Est=estParams(2);
varEst=abs(estParams(3));
scale1Est=estParams(4);
scale2Est=estParams(5);
offsetEst=estParams(6);


%%
function bigauss=gFitFun(p,x)%,data,WhichFit,fixVals) %just input the parameters as p and the x values as x to make a function which is compared against the input data by lsqcurvefit

gauss1  = (p(4).*(exp(-(x-p(1)).^2 / (2*(p(3).^2))))); %1st Gaussian function
gauss2  = (p(5).*(exp(-(x-p(2)).^2 / (2*(p(3).^2)))));
bigauss = gauss1+gauss2+p(6);

%err1=sum((prob-data).^2);

