function [uEst,varEst1,varEst2,scaleEst1,scaleEst2,offsetEst,thetaEst] = FitBiGaussian(inputs,prop,WhichFit,paramVals)
% [uEst,varEst,scaleEst] = FitGaussian(inputs,prop,[WhichFit],[paramVals])
%
% Fits a Gaussian function to the passed yes-no data.
% Requires the optimization toolbox.
%
% If you use the form 'FitGaussian(inputs,prop)' you'll get the usual
% 4-parameter fit (mean,variance,scalar)
%
% If you specify the second parameter 'WhichFit' to be e.g. [1 0 1 1]
% the routine will fit only the mean and scalar and use the supplied
% variance.
%
% If you specify the final parmaeter 'paramVals' you can give values to use
% for the unfitted variables
% e.g. 'FitGaussian(inputs,prop,[1 1 0 1],0.5)' will fit with a fixed scalar of 0.5
% eg. x=[-45:15:45];prob=[0.4 0.9 0.3 0.1 0.3 0.8 0.2];[uE,v1E,v2E,s1E,s2E,oE,tE]=FitBiGaussian(x,prob,[1 1 1 1 1 1 1]);xFine=[-45:0.1:45];prob2=DrawBiGaussian(xFine,uE,v1E,v2E,s1E,s2E,oE,tE);plot(x,prob,'o',xFine,prob2,'-');

% Sets up an initial guess for the parameters
meanGuess       = sum(inputs.*prop)/(sum(prop));
maxprop = find((prop==max(prop))); meanprop = find((inputs==mean(inputs))); %find indices of max and mean values of prop to estimate bimodality (use x to find scale middle)
[ThrowMean varGuess1 scalarGuess1 Throwoffset]=FitGaussian(inputs(1:meanprop),prop(1:meanprop),[1 1 1 1]); %fit a gaussian to half the data to estimate variance (throw others away)
[ThrowMean varGuess2 scalarGuess2 Throwoffset]=FitGaussian(inputs(meanprop:end),prop(meanprop:end),[1 1 1 1]); %fit a gaussian to half the data to estimate variance (throw others away)
%varGuess        = sum(prop.*(inputs-meanGuess).^2)./(sum(prop));
%scalarGuess     = 0.5*scalarGuess;%max(prop)-min(prop);%round(0.5*(max(prop)/max(NormalPDF(inputs,meanGuess,varGuess)))); %halve this value due to superimposition of two curves
offsetGuess     = min(prop);
thetaGuess      = 2*abs(inputs(maxprop(1))-inputs(meanprop)); %2*prop(round(abs(meanprop-maxprop(1)))); %take first value of max incase have two equal bimodal values

defVals=[meanGuess varGuess1 varGuess2 scalarGuess1 scalarGuess2 offsetGuess thetaGuess]; % Default parameters for fit
fixVals=defVals; % Parameters that will be filled in in the absence of user-provided values
    
if ~exist('WhichFit') % If the user didn'y specify which parmeters to fit...
    WhichFit=[1 1 1 1 1 1 1]; % ... assume they want to fit everything
end
 
guess1=defVals(find(WhichFit)); % Initial guess for the parmeters to be fit 
if exist('paramVals')
    fixVals(find(~WhichFit))=paramVals; % If user gave us some fixed params slot them into fixVals
end
 
opt = optimset(optimset,'MaxFunEvals',10000,'MaxIter',10000);
[x,err1] = fminsearch(@gFitFun,guess1,opt,inputs,prop,WhichFit,fixVals); % Does the fit
 
% Make a list of the all the fit and fixed params
estParams=[0 0 0 0 0 0 0];
estParams(find(WhichFit))=x;
estParams(find(~WhichFit))=fixVals(find(~WhichFit)); 
uEst=estParams(1);
varEst1=estParams(2);
varEst2=estParams(3);
scaleEst1=estParams(4);
scaleEst2=estParams(5);
offsetEst=estParams(6);
thetaEst=estParams(7);
 
%plot(inputs,prop,'o',inputs,scaleEst.*NormalPDF(inputs,uEst,varEst^2),'r-'); drawnow
 
%% 
function err1=gFitFun(InParams,x,data,WhichFit,fixVals)
p=[0 0 0 0 0 0 0];
p(find(WhichFit))=InParams;
p(find(~WhichFit))=fixVals(find(~WhichFit));

u1    = p(1)-round(0.5*p(7)); %mean for each gaussian determined by delta theta
u2    = p(1)+round(0.5*p(7));
prob1 = (p(4).*(exp(-(x-u1).^2 / (2*(p(2).^2))))); %Gaussian function  prob1=p(4)*NormalPDF(x,u1,p(2)^2);
prob2 = (p(5).*(exp(-(x-u2).^2 / (2*(p(3).^2))))); %Gaussian function  prob2=p(5)*NormalPDF(x,u2,p(3)^2);
prob  =(prob1+prob2)+p(6); %add offset equally to both

err1=sum((prob-data).^2);
%plot(x,data,'o',x,prob,'r-'); drawnow 

