function [uEst,LvarEst,RvarEst,scaleEst,offsetEst,err1] = FitSkewGaussian(xvals,prop,minparams,maxparams)
% [uEst,LvarEst,RvarEst,scaleEst,offsetEst,err1] = FitSkewGaussian(xvals,prop,minparams,maxparams)
%
% Fits a skewed Gaussian function to the passed data.
% Now uses lsqcurvefit instead of fminsearch
% Uses 5 parameters: mean (i.e. peak location), variance (left and right sides), scale (height), offset (base height)
% also returns the residual error of the fit to the data (for each x-axis position)
%
% If you use the form 'FitSkewGaussian(xvals,prop)' you'll get the usual
% 5-parameter fit (mean,L+R variances,scale,offset)
%
% With minparams and maxparams you can constrain the range of each of the four parameters (in order of entry above)
% Default is minparams = [-Inf 0 0 -Inf -Inf], maxparams = [Inf Inf Inf Inf Inf];
% where Inf values are unconstrained (so only variance is constrained to have positive values)
% If you want to restrict parameters to a range then this can be done. If you want a fixed value,
% you can't enter the same value for min and max but can enter an arbitrarily small range e.g. -0.01 to 0.01
%
%
% eg. x=[-45:15:45];prob=[0.1 0.2 0.6 0.9 0.3 0.1 0];[uE,LvE,RvE,sE,oE,lse]=FitSkewGaussian(x,prob,[-Inf 0 0 -Inf -Inf],[Inf Inf Inf Inf]);xFine=[-45:0.1:45];prob2=DrawSkewGaussian(xFine,uE,LvE,RvE,sE,oE);plot(x,prob,'o',xFine,prob2,'-');
%
% J Greenwood 2015

guessprop = prop./max(prop(:)); %make sure data is converted to proportions for guess parameters

% Set up an initial guess for the 5 parameters
meanGuess       = sum(xvals.*guessprop)/(sum(guessprop));
offsetGuess     = min(prop);

%divide data into LHS and RHS based on mean guess (to get LHS and RHS variance guesses)
[~,minind]=min(abs(xvals-meanGuess)); %find the x-axis location of the mean guess-value

leftgprop  = [guessprop(1:minind) fliplr(guessprop(1:minind-1))];
rightgprop = [guessprop(minind:end) fliplr(guessprop(minind+1:end))];

newX       = xvals-meanGuess;
leftxvals  = [newX(1:minind) fliplr(newX(1:minind-1))]; %make a new x-axis as well
rightxvals = [newX(minind:end) fliplr(newX(minind+1:end))];

LvarGuess  = abs(var((leftgprop-min(leftgprop)).*(leftxvals-meanGuess)));%abs(sum((guessprop-offsetGuess).*(xvals-meanGuess).^2)./(sum(guessprop-offsetGuess))); %NB only positive variance
RvarGuess  = abs(var((rightgprop-min(rightgprop)).*(rightxvals-meanGuess)));%abs(sum((guessprop-offsetGuess).*(xvals-meanGuess).^2)./(sum(guessprop-offsetGuess))); %NB only positive variance

scalarGuess     = max(prop)-mean(prop([1 end]));%range(prop);%abs((max(prop)/max((exp(-(xvals-meanGuess).^2 / (2*(varGuess.^2)))))-min(prop))); %NB only positive scale%(max(prop)/max((exp(-(xvals-meanGuess).^2 / (2*(varGuess.^2))))))-min(prop);

guessParams=[meanGuess LvarGuess RvarGuess scalarGuess offsetGuess]; % Default parameters for fit

if ~exist('minparams')
    minparams = [-Inf 0 0 -Inf -Inf]; %default is just to make sure variance isn't negative
end
if ~exist('maxparams')
    maxparams = [Inf Inf Inf Inf Inf]; %default is no upper bounds
end

opt = optimset(optimset,'MaxFunEvals',1000,'Display','off'); %options for the fit

% Actually do the fit
[estParams,~,err1] = lsqcurvefit(@gFitFun,guessParams,xvals,prop,minparams,maxparams,opt);

% Return all the parameters
uEst=estParams(1);
LvarEst=abs(estParams(2));
RvarEst=abs(estParams(3));
scaleEst=estParams(4);
offsetEst=estParams(5);


%%
function gauss=gFitFun(p,x)%,data,WhichFit,fixVals) %just input the parameters as p and the x values as x to make a function which is compared against the input data by lsqcurvefit

gLeft  = (p(4).*(exp(-(x-p(1)).^2 / (2*(p(2).^2)))))+p(5); %left gaussian function
gRight = (p(4).*(exp(-(x-p(1)).^2 / (2*(p(3).^2)))))+p(5); %right gaussian function

[~,minind]=min(abs(x-p(1))); %find the x-axis location of the mean value

gauss = [gLeft(1:minind-1) mean([gLeft(minind) gRight(minind)]) gRight(minind+1:end)]; %stitch together the skewed gaussian

%err1=sum((prob-data).^2);

