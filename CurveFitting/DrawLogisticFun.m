function yvals = DrawLogisticFun(xvals,k,midpt,minval,maxval)
%DrawLogisticFun
% function yvals = DrawLogisticFun(xvals,k,midpt,minval,maxval)
% function to draw a logistic curve
% 4 parameters: k (slope), midpt (midpoint of the function), minval (minimum yval), maxval (maximum yval)
%
% e.g. x = [0:0.1:200]; yvals = DrawLogisticFun(x,0.1,100,2,10); plot(x,yvals,'b-');
% John Greenwood v1.0, March 2020 lockdown

%yvals = maxval./(1+10.^(-((a.*xvals)+b)));
yvals  = ((maxval-minval)./(1+exp(-k.*(xvals-midpt))))+minval;
