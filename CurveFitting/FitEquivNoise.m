function [SDintEst NoSampEst] = FitEquivNoise(xval,yval,WhichFit,paramVals)
% [SDintEst NoSampEst] = FitEquivNoise(xval,yval,WhichFit,paramVals)
% e.g. xval = [0 20 40 60]; yval = [0.2 0.2 0.3 0.6]; [SDintEst NoSampEst] = FitEquivNoise(xval,yval); %[xval gab1] = DoGaussFirstDeriv([uEst varEst scaleEst],inputs); plot(xval,yval,'o',xval,gab1,'-')
%
% Fits a first-derivative of a Gaussian function to the passed data.
% Requires the optimization toolbox.

% If you use the form 'FitGaussian(inputs,prop)' you'll get the usual 3-parameter fit (mean,variance,scalar)
%
% If you specify the third parameter 'WhichFit' to be e.g. [1 0 1] the routine will fit only the mean and scalar and use the default variance.
%
% If you specify the final parmaeter 'paramVals' you can give values to use for the unfitted variables e.g. 'FitGaussian(inputs,prop,[1 1 0],0.5)' will fit with a fixed scalar of 0.5
% jgreenwood 2010
 
% Sets up an initial guess for the three parameters
SDintGuess  = 0.5*max(xval);%sum(inputs.*abs(yval))/(sum(abs(yval)));
NoSampGuess = 10;%sum(abs(yval).*(inputs-meanGuess).^2)./(sum(abs(yval)));

defVals=[SDintGuess NoSampGuess]; % Default parameters for fit
fixVals=defVals; % Parameters that will be filled in in the absence of user-provided values

if ~exist('WhichFit') % If the user didn'y specify which parmeters to fit...
    WhichFit=[1 1]; % ... assume they want to fit everything
end

guess1=defVals(find(WhichFit)); % Initial guess for the parmeters to be fit 
if exist('paramVals')
    fixVals(find(~WhichFit))=paramVals; % If user gave us some fixed params slot them into fixVals
end

opt = optimset(optimset,'MaxFunEvals',5000);
[x,err1] = fminsearch(@gFitFun,guess1,opt,xval,yval,WhichFit,fixVals); % Does the fit
 
% Make a list of the all the fit and fixed params
estParams=[0 0];
estParams(find(WhichFit))=x;
estParams(find(~WhichFit))=fixVals(find(~WhichFit)); 
SDintEst=estParams(1);
NoSampEst=estParams(2);

%plot(inputs,yval,'o',inputs,scaleEst.*NormalPDF(inputs,uEst,varEst^2),'r-'); drawnow
 
%% 
function err1=gFitFun(InParams,x,data,WhichFit,fixVals)
p=[0 0];
p(find(WhichFit))=InParams;
p(find(~WhichFit))=fixVals(find(~WhichFit));

SDobs = sqrt((p(1).^2 + x.^2)/p(2)); %equivalent noise function

err1=sum((SDobs-data).^2);
%plot(x,data,'o',x,prob,'r-'); drawnow 
