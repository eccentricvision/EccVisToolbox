%function [xnew ynew err Params] = fitDerivGauss(x,y)
%fit derivative-of-gaussian

x = [-40   -20   -10    -5     0     5    10    20    40]; %example x-axis
y = [-1.0544   -7.6473  -16.7676   -6.7734    1.3506   12.2072    9.5666    7.6839    2.1540];
%maxval = Params(1); sigma  = Params(2); offset = Params(3); sigma2szeRatio = Params(4);
Params = [5 10];
options = optimset('MaxFunEvals',1000,'MaxIter',1000);
NewParams = lsqcurvefit(@(Params,x) DoGaborFirstDeriv(Params,x),Params',x',y',[],[],options);



% [k t] = DoGaborDerivative(maxval,sigma,offset,sigma2szeRatio,order)
% 
% [k t] = DoGaborDerivative(2,6,50,5,5);

% options=optimset('Algorithm','active-set','MaxFunEvals',500,'MaxIter',500);
% %A = [1 1 1 1 1]; B = [5]; %contraints that all parameters are less than equal to 5
% %LB = [0.1 0.1 0.1 0.5 0.1]; UB = [1 1 1 1 1];
% %A = 1; B = 1; LB = 0.1; UB = 1
% 
% [Params,err] = fmincon(@DoGaborDerivative,[maxval sigma offset 0 1] ,[],[],[],[],[],[],[],options);
