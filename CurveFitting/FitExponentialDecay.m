function [NEst,TauEst,BaseEst,cutEst] = FitExponentialDecay(xval,yval,WhichFit,paramVals,cuts)
% [NEst,TauEst,cutEst] = FitExponentialDecay(xval,yval,WhichFit,paramVals,cuts)
% cuts returns the values request along the function (from 0-100);
% see e.g. BimodalAngSepThreshTimeData.m for example
%
% Fits a decaying exponential function to the passed data. y = N .* exp(-t/Tau)
% Requires the optimization toolbox.

% If you use the form 'FitPower(inputs,prop)' you'll get the usual 2-parameter fit
% If you specify the third parameter 'WhichFit' to be e.g. [1 0] the routine will fit only those parameters and use the default tau.
%
% jgreenwood September 2016

% Sets up an initial guess for the three parameters
NGuess   = max(yval(:))-min(yval(:));
TauGuess = xval(end-1);
BaseValGuess = min(yval(:));

defVals=[NGuess TauGuess BaseValGuess]; % Default parameters for fit
fixVals=defVals; % Parameters that will be filled in in the absence of user-provided values

if ~exist('WhichFit') % If the user didn'y specify which parmeters to fit...
    WhichFit=[1 1 1]; % ... assume they want to fit everything
end

guess1=defVals(find(WhichFit)); % Initial guess for the parmeters to be fit 
if exist('paramVals')
    fixVals(find(~WhichFit))=paramVals; % If user gave us some fixed params slot them into fixVals
end

opt = optimset(optimset,'MaxFunEvals',100000);
[x,err1] = fminsearch(@gFitFun,guess1,opt,xval,yval,WhichFit,fixVals); % Does the fit
 
% Make a list of the all the fit and fixed params
estParams=[0 0 0];
estParams(find(WhichFit))=x;
estParams(find(~WhichFit))=fixVals(find(~WhichFit)); 
NEst=estParams(1);
TauEst =estParams(2);
BaseEst=estParams(3);

xfine = min(xval):0.0001:max(xval);
prob = DrawExponentialDecayFunc(xfine,NEst,TauEst,0); %run curve fit to extract cut values for midpoint, threshold etc
prob = (prob./max(prob))*100; %scale from 0-100
for cc=1:length(cuts)
    vals=abs(prob-cuts(cc)); %find the point where curve gets closest to desired cut point
    temp = xfine(find(vals==min(min(vals)))); %take minimum of function
    if numel(temp)>1
        cutEst(cc) = temp(round(length(temp)/2)); %take middle element
    else
        cutEst(cc) = temp;
    end
end

%% 
function err1=gFitFun(InParams,x,data,WhichFit,fixVals)
p=[0 0 0];
p(find(WhichFit))=InParams;
p(find(~WhichFit))=fixVals(find(~WhichFit));

yFit = (p(1).*(exp(-x./p(2))))+p(3); %power function

err1=sum((yFit-data).^2);
%plot(x,data,'o',x,prob,'r-'); drawnow 
