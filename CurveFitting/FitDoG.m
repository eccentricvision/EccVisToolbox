function [uEst,var1Est,var2Est,scale1Est,scale2Est,offsetEst] = FitDoG(inputs,prop,WhichFit,paramVals)
% [uEst,var1Est,var2Est,scale1Est,scale2Est,offsetEst] = FitDoG(inputs,prop,WhichFit,paramVals)
%
% Fits a Difference of Gaussian ("Mexican Hat") function to the passed data.
% Requires the optimization toolbox.
% Six parameters: mean (i.e. peak location), variances 1 and 2, scale (height) 1 and 2, and offset (base height)
%
% If you use the form 'FitDoG(inputs,prop)' you'll get the usual
% 6-parameter fit (mean,variance1&2,scale1&2,offset)
%
% If you specify the third parameter 'WhichFit' to be e.g. [0 1 1 1 1 1]
% the routine will fit everything except the mean
%
% If any of the 'WhichFit' values are 0 then you specify the final parameter 'paramVals' to use for the unfitted variables
% e.g. 'FitDoG(inputs,prop,[1 1 1 1 1 0],0.5)' will fit with a fixed base offset height of 0.5
% or   'FitDoG(inputs,prop,[0 1 1 1 1 0],[90 0.5])' will fit with a fixed mean at 90 and a base offset height of 0.5
%
% eg1. x=[-56:8:56];prob=[0 0.1 0 -0.2 -0.4 0 0.4 0.9 0.3 0 -0.3 -0.15 0.1 0 0];[uE,v1E,v2E,s1E,s2E,oE]=FitDoG(x,prob,[1 1 1 1 1 1]);xFine=[-56:0.1:56];prob2=DrawDoG(xFine,uE,v1E,v2E,s1E,s2E,oE);plot(x,prob,'o',xFine,prob2,'-');
% eg2. x=[-45:15:45];prob=[0.1 0 0.4 0.9 0.3 0.1 0];[uE,v1E,v2E,s1E,s2E,oE]=FitDoG(x,prob,[1 1 1 1 1 1]);xFine=[-45:0.1:45];prob2=DrawDoG(xFine,uE,v1E,v2E,s1E,s2E,oE);plot(x,prob,'o',xFine,prob2,'-');
%
% J Greenwood 2015

% Sets up an initial guess for the six parameters

offsetGuess     = min([prop(1) prop(end)]); %take the first and last points as guess for the base offset
prop2           = prop-offsetGuess;
prop2(prop2<0)  = 0; %just take the central peak to fit for var1Guess and others

[meanGuess,var1Guess,scale1Guess,oE]=FitGaussian(inputs,prop2,[1 1 1 1]); %fit a gaussian to the central peak to get some guess parameters
%meanGuess       = sum(inputs.*prop)/(sum(prop));
%var1Guess       = abs(sum((prop2).*(inputs).^2)./(sum(prop2)));
%scale1Guess     = (max(prop2)/max((exp(-(inputs-meanGuess).^2 / (2*(var1Guess.^2)))))-min(prop2));
%prop2           = prop-offsetGuess;
%propneg         = prop2(find(prop2<0));
%inputneg        = inputs(find(prop2<0));
%prop2(prop2>0)  = -prop2(prop2>0); %flip the central peak to fit the negative component
%if isempty(propneg)
%    var2Guess   = 0;
%    scale2Guess = 0;
%else
%    [uE,var2Guess,scale2Guess,oE]=FitGaussian(inputneg,-propneg,[0 1 1 1],meanGuess);
%end
scale2Guess      = scale1Guess./3; %guess that the scale of the second is 1/3 of the first
var2Guess        = var1Guess.*2; %guess that the variance of the second is twice the first
%var2Guess       = abs(sum((-prop2).*(inputs).^2)./(sum(-prop2)));
%var2Guess       = abs(sum((prop-offsetGuess).*(inputs-meanGuess).^2)./(sum(prop-offsetGuess)));
%var1Guess       = var2Guess./3;
%prop2           = prop-offsetGuess;
%prop2           = prop2(prop2>0);
%input2          = inputs(prop2>0);
%scale2Guess     = -min(prop2);%(max(prop2)/max((exp(-(input2-meanGuess).^2 / (2*(var2Guess.^2)))))-min(prop2))./2;%scale1Guess./2;%
%scale1Guess     = scale1Guess + scale2Guess; %since the -ve component is taken off the central gaussian
%scale1Guess     = (max(prop)/max((exp(-(inputs-meanGuess).^2 / (2*(var1Guess.^2)))))-min(prop)); %(max(prop)/max((exp(-(inputs-meanGuess).^2 / (2*(varGuess.^2))))))-min(prop);
%scale2Guess     = offsetGuess-min(prop);

defVals=[meanGuess var1Guess var2Guess scale1Guess scale2Guess offsetGuess]; % Default parameters for fit
fixVals=defVals; % Parameters that will be filled in in the absence of user-provided values

if ~exist('WhichFit') % If the user didn'y specify which parmeters to fit...
    WhichFit=[1 1 1 1 1 1]; % ... assume they want to fit everything
end

guess1=defVals(find(WhichFit)); % Initial guess for the parmeters to be fit
if exist('paramVals')
    fixVals(find(~WhichFit))=paramVals; % If user gave us some fixed params slot them into fixVals
end

opt = optimset(optimset,'MaxFunEvals',100000);
[x,err1] = fminsearch(@gFitFun,guess1,opt,inputs,prop,WhichFit,fixVals); % Does the fit

% Make a list of the all the fit and fixed params
estParams=[0 0 0 0 0 0];
estParams(find(WhichFit))=x;
estParams(find(~WhichFit))=fixVals(find(~WhichFit));
uEst      = estParams(1);
var1Est    = abs(estParams(2));
var2Est   = abs(estParams(3));
if var2Est<var1Est
    var2Est=0; %can't have the negative gaussian slimmer than the positive
end
scale1Est = estParams(4);
scale2Est = estParams(5);
offsetEst = estParams(6);

%%
function err1=gFitFun(InParams,x,data,WhichFit,fixVals)
p=[0 0 0 0 0 0];
p(find(WhichFit))=InParams;
p(find(~WhichFit))=fixVals(find(~WhichFit));
p(2) = abs(p(2)); %absolute variance only
p(3) = abs(p(3)); %absolute variance only
if p(3)<p(2)
    p(3)=0; %can't have the negative gaussian slimmer than the positive
end
% if p(5)>p(4)
%     p(5)=p(4); %can't have the scale of the negative component greater than the positive
% end

prob1 = (p(4).*(exp(-(x-p(1)).^2 / (2*(p(2).^2))))); %positive Gaussian function
prob2 = (p(5).*(exp(-(x-p(1)).^2 / (2*(p(3).^2))))); %negative Gaussian function
prob  = prob1 - prob2 + p(6);

err1=sum((prob-data).^2);
