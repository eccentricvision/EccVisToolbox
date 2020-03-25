function [alphaEst,gammaEst,baseEst,cutEst] = FitPower(xval,yval,WhichFit,paramVals,cuts)
% [alphaEst,gammaEst,baseEst,cutEst] = FitPower(xval,yval,WhichFit,paramVals,cuts)
% cuts returns the values request along the function (from 0-100);
% e.g. xval = [0 20 40 60]; yval = [0.2 0.2 0.3 0.6]; [alphaEst,gammaEst,baseEst,cutEst] = FitPower(xval,yval,[1 1 1],0,[5 50 95]); [yFit] = DrawPowerFunc([0:0.1:60],alphaEst,gammaEst,baseEst); plot(xval,yval,'o',[0:0.1:60],yFit,'-')
%
% Fits a power function to the passed data. y = alphaEst.*(x.^gammaEst) + baseEst;
% Requires the optimization toolbox.

% If you use the form 'FitPower(inputs,prop)' you'll get the usual 3-parameter fit
% If you specify the third parameter 'WhichFit' to be e.g. [1 0 1] the routine will fit only those parameters and use the default variance.
%
% If you specify the final parmaeter 'paramVals' you can give values to use for the unfitted variables e.g. 'FitGaussian(inputs,prop,[1 1 0],0.5)' will fit with a fixed scalar of 0.5
% jgreenwood 2010

% Sets up an initial guess for the three parameters
gammaGuess = 3;%sum(abs(yval).*(xval-mean(xval)).^2)./(sum(abs(yval))); %3
baseGuess  = min(yval);
alphaGuess = (max(yval)-baseGuess)./max(xval.^gammaGuess);%gives approximate alpha value based on guess parameters %0.00001;

defVals=[alphaGuess gammaGuess baseGuess]; % Default parameters for fit
fixVals=defVals; % Parameters that will be filled in in the absence of user-provided values

if ~exist('WhichFit') % If the user didn'y specify which parmeters to fit...
    WhichFit=[1 1 1]; % ... assume they want to fit everything
end

guess1=defVals(find(WhichFit)); % Initial guess for the parmeters to be fit 
if exist('paramVals')
    fixVals(find(~WhichFit))=paramVals; % If user gave us some fixed params slot them into fixVals
end

opt = optimset(optimset,'MaxFunEvals',100000);%,'TolFun',1e-6,'TolX',1e-6);
[x,err1] = fminsearch(@gFitFun,guess1,opt,xval,yval,WhichFit,fixVals); % Does the fit
 
% Make a list of the all the fit and fixed params
estParams=[0 0];
estParams(find(WhichFit))=x;
estParams(find(~WhichFit))=fixVals(find(~WhichFit)); 
alphaEst=estParams(1);
gammaEst=estParams(2);
baseEst =estParams(3);

xfine = min(xval):0.0001:max(xval);
prob = DrawPowerFunc(xfine,alphaEst,gammaEst,baseEst); %run curve fit to extract cut values for midpoint, threshold etc
prob = (prob./max(prob))*100;
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
p=[0 0];
p(find(WhichFit))=InParams;
p(find(~WhichFit))=fixVals(find(~WhichFit));

yFit = p(1).*(x.^p(2)) + p(3); %power function

err1=sum((yFit-data).^2);
%plot(x,data,'o',x,prob,'r-'); drawnow 
