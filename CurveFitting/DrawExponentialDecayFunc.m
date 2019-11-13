function yvals = DrawExponentialDecayFunc(xvals,Nzero,Tau,BaseVal)
% function yvals = DrawExponentialDecayFunc(xvals,Nzero,Tau,BaseVal)
% Draw an exponential decay function of the form y = (Nzero .* exp(-t/Tau))+BaseVal;
% see e.g. BimodalAngSepThreshTimeData.m for example
%
% J Greenwood Sept 2016

yvals=Nzero.*(exp(-xvals./Tau))+BaseVal; %power function
