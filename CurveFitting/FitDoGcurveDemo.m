%FitDoGcurveDemo
%demo file to use John's magical DoG / MexHat curve fitting functions

xvals = linspace(-5,5,23); %this is your x-axis, e.g. between -5deg to +5deg in 17 steps

%some example data: switch out different yvals to see different types of fit
%below are all made-up yvals - data can be on any scale
yvals = [0.5 0.6 0.5 0.4 0.3 0.2 0.3 0.6 0.8 0.9 1.2 1.3 1.1 0.7 0.6 0.5 0.3 0.2 0.3 0.4 0.4 0.5 0.5];
%yvals = [5 5 4 3 0 -1 -5 -2 3 5 9 12 8 4 2 -1 -6 -3 -1 1 3 4 5]; 
%yvals = [5 5 4 3 2 3 5 8 12 15 19 22 18 14 12 7 4 3 2 3 3 5 5]; 
%yvals = [0 0 0 0 0 0 1 3 5   7  9 11 10 8  6  4 2 1 0 0 0 0 0]; %normal gaussian - sanity check to see it works for non-DoG data 

%now we fit the curve
%use FitDoG.m first - requires the optimization toolbox.
% Fits six parameters: mean (i.e. peak location), variances 1 and 2, scale (height) 1 and 2, and offset (base height)
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

[uVal,var1Val,var2Val,scale1Val,scale2Val,offVal]=FitDoG(xvals,yvals,[1 1 1 1 1 1],0);

%now draw the function that you've just fit
%use DrawDoG for this and put in the parameters returned above
%fits will look best if you draw it with a finer x-axis than your data

xFine = [-5:0.1:5]; %fine-scale version of x-axis for plotting curve
dogfit = DrawDoG(xFine,uVal,var1Val,var2Val,scale1Val,scale2Val,offVal);

%now plot it all
plot(xvals,yvals,'o',xFine,dogfit,'-');
