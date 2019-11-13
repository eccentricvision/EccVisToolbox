function [uEst,varEst,scaleEst,offsetEst,err1] = FitGaussian(xvals,prop,minparams,maxparams)
% [uEst,varEst,scaleEst,offsetEst,err1] = FitGaussian(xvals,prop,minparams,maxparams)
%
% Fits a Gaussian function to the passed data.
% Now uses lsqcurvefit instead of fminsearch
% Uses four parameters: mean (i.e. peak location), variance, scale (height), offset (base height)
% also returns the residual error of the fit to the data (for each x-axis position)
%
% If you use the form 'FitGaussian(xvals,prop)' you'll get the usual
% 4-parameter fit (mean,variance,scale,offset)
%
% With minparams and maxparams you can constrain the range of each of the four parameters (in order of entry above)
% Default is minparams = [-Inf 0 -Inf -Inf], maxparams = [Inf Inf Inf Inf];
% where Inf values are unconstrained (so only variance is constrained to have positive values)
% If you want to restrict parameters to a range then this can be done. If you want a fixed value,
% you can't enter the same value for min and max but can enter an arbitrarily small range e.g. -0.01 to 0.01
%
%
% eg. x=[-45:15:45];prob=[0.1 0 0.4 0.9 0.3 0.1 0];[uE,vE,sE,oE,lse]=FitGaussian(x,prob,[-Inf 0 -Inf -Inf],[Inf Inf Inf Inf]);xFine=[-45:0.1:45];prob2=DrawGaussian(xFine,uE,vE,sE,oE);plot(x,prob,'o',xFine,prob2,'-');
% eg2.x=[-45:15:45];prob=[0.1 0 0.4 0.9 0.3 0.1 0];[uE,vE,sE,oE,lse]=FitGaussian(x,prob,[-0.01 0 -Inf -Inf],[0.01 Inf Inf Inf]);xFine=[-45:0.1:45];prob2=DrawGaussian(xFine,uE,vE,sE,oE);plot(x,prob,'o',xFine,prob2,'-');
%
% J Greenwood 2015

guessprop = prop./max(prop(:)); %make sure data is converted to proportions for guess parameters

% Set up an initial guess for the four parameters
meanGuess       = sum(xvals.*guessprop)/(sum(guessprop));
offsetGuess     = min(prop);
varGuess        = abs(var((guessprop-min(guessprop)).*(xvals-meanGuess)));%abs(sum((guessprop-offsetGuess).*(xvals-meanGuess).^2)./(sum(guessprop-offsetGuess))); %NB only positive variance
scalarGuess     = max(prop)-mean(prop([1 end]));%max(prop)-mean(prop([1 2 end-1 end]));

guessParams=[meanGuess varGuess scalarGuess offsetGuess]; % Default parameters for fit

if ~exist('minparams')
    minparams = [-Inf 0 -Inf -Inf]; %default is just to make sure variance isn't negative
end
if ~exist('maxparams')
    maxparams = [Inf Inf Inf Inf]; %default is no upper bounds
end

opt = optimset(optimset,'MaxFunEvals',1000,'Display','off'); %options for the fit

% Actually do the fit
[estParams,~,err1] = lsqcurvefit(@gFitFun,guessParams,xvals,prop,minparams,maxparams,opt);

% Return all the parameters
uEst=estParams(1);
varEst=abs(estParams(2));
scaleEst=estParams(3);
offsetEst=estParams(4);


%%
function gauss=gFitFun(p,x)%,data,WhichFit,fixVals) %just input the parameters as p and the x values as x to make a function which is compared against the input data by lsqcurvefit

gauss=(p(3).*(exp(-(x-p(1)).^2 / (2*(p(2).^2)))))+p(4); %Gaussian function

%err1=sum((prob-data).^2);

