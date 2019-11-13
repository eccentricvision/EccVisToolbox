function [uEst varEst scaleEst] = FitGaussFirstDeriv(inputs,yval,WhichFit,paramVals)
% [uEst,varEst,scaleEst] = FitGaussFirstDeriv(inputs,yval,[WhichFit],[paramVals])
% e.g. inputs = [-40 -20 -10 -5 0 5 10 20 40]; yval = [-1.05 -7.65 -16.77 -6.77 1.35 12.21 9.57 7.68 2.15]; [uEst varEst scaleEst] = FitGaussFirstDeriv(inputs,yval); [xfine gab1] = DoGaussFirstDeriv([uEst varEst scaleEst],[min(inputs):0.1:max(inputs)]); plot(inputs,yval,'o',xfine,gab1,'-')
%
% Fits a first-derivative of a Gaussian function to the passed data.
% Requires the optimization toolbox.

% If you use the form 'FitGaussian(inputs,prop)' you'll get the usual 3-parameter fit (mean,variance,scalar)
%
% If you specify the third parameter 'WhichFit' to be e.g. [1 0 1] the routine will fit only the mean and scalar and use the default variance.
%
% If you specify the final parmaeter 'paramVals' you can give values to use for the unfitted variables e.g. 'FitGaussian(inputs,prop,[1 1 0],0.5)' will fit with a fixed scalar of 0.5
% (modified code from Steven)
 
% Sets up an initial guess for the three parameters
meanGuess       = sum(inputs.*abs(yval))/(sum(abs(yval)));
varGuess        = sum(abs(yval).*(inputs-meanGuess).^2)./(sum(abs(yval)));
scalarGuess     = max(abs(yval));%mean([max(yval) abs(min(yval))]);%/max(NormalPDF(inputs,meanGuess,varGuess));
defVals=[meanGuess varGuess scalarGuess]; % Default parameters for fit
fixVals=defVals; % Parameters that will be filled in in the absence of user-provided values

if ~exist('WhichFit') % If the user didn'y specify which parmeters to fit...
    WhichFit=[1 1 1]; % ... assume they want to fit everything
end

guess1=defVals(find(WhichFit)); % Initial guess for the parmeters to be fit 
if exist('paramVals')
    fixVals(find(~WhichFit))=paramVals; % If user gave us some fixed params slot them into fixVals
end

opt = optimset(optimset,'MaxFunEvals',5000);
[x,err1] = fminsearch(@gFitFun,guess1,opt,inputs,yval,WhichFit,fixVals); % Does the fit
 
% Make a list of the all the fit and fixed params
estParams=[0 0 0];
estParams(find(WhichFit))=x;
estParams(find(~WhichFit))=fixVals(find(~WhichFit)); 
uEst=estParams(1);
varEst=estParams(2);
scaleEst=estParams(3);

%plot(inputs,yval,'o',inputs,scaleEst.*NormalPDF(inputs,uEst,varEst^2),'r-'); drawnow
 
%% 
function err1=gFitFun(InParams,x,data,WhichFit,fixVals)
p=[0 0 0];
p(find(WhichFit))=InParams;
p(find(~WhichFit))=fixVals(find(~WhichFit));

basegauss=((exp(-(x-p(1)).^2 /(2*(p(2).^2))))); %Gaussian function
%basegauss = NormalPDF(x,p(1),p(2)^2); % Calculate the gaussian,
gab1 = (-1).^1.*(2*x).*basegauss; % apply Hermite polynomial to gauss (1st derivative)
gab1 = -gab1;
gab1 = (gab1/max(gab1))*p(3); %normalise and set to maximum value of dataset required

err1=sum((gab1-data).^2);
%plot(x,data,'o',x,prob,'r-'); drawnow 
