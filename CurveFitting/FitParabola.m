function [m,b,err1] = FitParabola(x,y,WhichFit,paramVals)
% [m,b] = FitParabola(x,y)
%
% Fits a parabola to the passed (x,y) data
% Requires the optimization toolbox.
% WhichFit = 0/1 which parameters to fit: [1 1] for all
% paramVals = vals to input for fixed values, or [] if not
% returns 2 parameters: m (scale value) & b (baseline value), plus error
% NB assumes parabola is centred on 0 with x-axis extending -ve to +ve
% otherwise need to fit the inflection point, see FitLineParabola
%
% e.g. x=-5:5; y=[2.5056 2.3402 1.8020 1.6321 1.4427 1.2 1.3427 1.4020 1.8321 2.1056 2.3402]; [m,b]=FitParabola(x,y,[1 1],[]); x2 = [min(x):0.001:max(x)]; y2 = DrawParabola(x2,m,b); plot(x,y,'ro',x2,y2,'b-');
%
%J Greenwood Oct 2021

% Sets up an initial guess for the three parameters
%mGuess  = 1;
mGuess  = 1;
bGuess  = min(y); %most likely shift is the min value

if ~exist('WhichFit') % If the user didn'y specify which parmeters to fit...
    WhichFit=[1 1]; % ... assume they want to fit everything
end

defVals=[mGuess bGuess]; % Parameters that will be filled in in the absence of user-provided values
fixVals=defVals;
guess1=defVals(find(WhichFit)); % Initial guess for the parmeters to be fit 
if exist('paramVals')
    fixVals(find(~WhichFit))=paramVals; % If user gave us some fixed params slot them into fixVals
end

opt = optimset(optimset,'MaxFunEvals',1000);
[x,err1] = fminsearch(@gFitFun,guess1,opt,x,y,WhichFit,fixVals); % Does the fit

estParams=[0 0 0];
estParams(find(WhichFit))=x;
estParams(find(~WhichFit))=fixVals(find(~WhichFit)); 

m=estParams(1);
b=estParams(2);
 
%% 
function [err1]=gFitFun(InParams,x,y,WhichFit,fixVals)

p=[0 0];
p(find(WhichFit))=InParams;
p(find(~WhichFit))=fixVals(find(~WhichFit));

prob=(p(1).*(x.^2))+p(2); %y = m*((x).^2)+b
err1=sum((prob-y).^2);
