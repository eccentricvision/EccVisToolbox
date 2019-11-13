function [m,b,err1] = FitLine(x,y)
% [m,b] = FitLine(x,y)
%
% Fits a line to the passed (x,y) data
% Requires the optimization toolbox.
%
% e.g. x=[3.38 0.81 1.61 1.60 3.70 1.48 3.92 2.75 1.08 2.12 2.08 1.92 0.82 2.26 6.53 1.48 1.11]; y=[1.57 0.79 1.15 1.18 1.45 1.44 1.80 1.69 0.83 1.36 1.45 1.04 1.08 1.27 3.46 0.79 0.93]; [m,b]=FitLine(x,y); x2 = [min(x):0.001:max(x)]; y2 = DrawLine(x2,m,b); plot(x,y,'ro',x2,y2,'b-');
%
%J Greenwood 2010

% Sets up an initial guess for the three parameters
mGuess  = 1;
bGuess  = 0;

guess1=[mGuess bGuess]; % Parameters that will be filled in in the absence of user-provided values

opt = optimset(optimset,'MaxFunEvals',1000);
[x,err1] = fminsearch(@gFitFun,guess1,opt,x,y); % Does the fit
 
m=x(1);
b=x(2);
 
%% 
function [err1]=gFitFun(p,x,y)

prob=(p(1).*x)+p(2); %y = mx+b
err1=sum((prob-y).^2);
