function [m,b,s,err1] = FitLineParabola(x,y,WhichFit,paramVals)
% [m,b] = FitLineParabola(x,y)
%
% Fits a line + parabola to the passed (x,y) data
% Requires the optimization toolbox.
% WhichFit = 0/1 which parameters to fit
% paramVals = vals to input;
%
% e.g. x=[1 2 3 4 5]; y=[1.8427 1.4020 1.6321 2.5056 2.3402]; [m,b,s]=FitLineParabola(x,y,[1 1 1]); x2 = [min(x):0.001:max(x)]; y2 = DrawLineParabola(x2,m,b,s); plot(x,y,'ro',x2,y2,'b-');
%
%J Greenwood 2010

% Sets up an initial guess for the three parameters
mGuess  = 1;
bGuess  = min(y); %most likely shift is the min value
sGuess  = x(y==min(y)); %point of inflexion

if ~exist('WhichFit') % If the user didn'y specify which parmeters to fit...
    WhichFit=[1 1 1]; % ... assume they want to fit everything
end

defVals=[mGuess bGuess sGuess]; % Parameters that will be filled in in the absence of user-provided values
fixVals=defVals;
guess1=defVals(find(WhichFit)); % Initial guess for the parmeters to be fit 
if exist('paramVals')
    fixVals(find(~WhichFit))=paramVals; % If user gave us some fixed params slot them into fixVals
end

opt = optimset(optimset,'MaxFunEvals',10000);
[x,err1] = fminsearch(@gFitFun,guess1,opt,x,y,WhichFit,fixVals); % Does the fit

estParams=[0 0 0];
estParams(find(WhichFit))=x;
estParams(find(~WhichFit))=fixVals(find(~WhichFit)); 

m=estParams(1);
b=estParams(2);
s=estParams(3);
 
%% 
function [err1]=gFitFun(InParams,x,y,WhichFit,fixVals)

p=[0 0 0];
p(find(WhichFit))=InParams;
p(find(~WhichFit))=fixVals(find(~WhichFit));

prob=(p(1).*((x-p(3)).^2))+p(2); %y = m*((x-s).^2)+b
err1=sum((prob-y).^2);
