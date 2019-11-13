function yvals = DrawDoBiGaussian(xvals,param)
%function yvals = DrawDoBiGaussian(xvals,param);
%draws a 'difference of bimodal gaussians' function using 7 parameters
%xvals = xaxis to draw across, params = structure for parameters
%1st Gaussian has 4 parameters - param.u = mean, param.var = variance, 
%param.scale1 = peak height, param.offset = baseline offset 
%(i.e. zero point of the middle curve)
%2nd Gaussian has 3 parameters - param.uDiff = difference between the means of the two
%component gaussians (centred on param.u), param.scaleLeft = peak height of
%left-side negative gaussian, likewise for param.scaleRight
%(note second negative gaussians use same variance, offset and overall mean
%as the first gaussian - to reduce parameters)
%
%J Greenwood March 2016, based on what is now DrawDoBiGaussian_old.m
%
%e.g. xvals = 0:22.5:180; yplot = [0.76 0.37 0.30 0.96 1.22 0.82 0.56 0.61 0.76]; xFine = 0:0.1:180; param.u = 88.06; param.var = 20.4; param.scale1=0.5; param.offset = 0.8;param.uDiff = 90;param.scaleLeft = 0.55;param.scaleRight=0.25; yvals = DrawDoBiGaussian(xFine,param);plot(xvals,yplot,'ro',xFine,yvals,'b-');

gauss1     = (param.scale1.*(exp(-(xvals-param.u).^2 / (2*(param.var.^2)))))+param.offset; %positive Gaussian function

param.uLeft  = param.u - (param.uDiff/2); %set the mean of the left-side negative gaussian
param.uRight = param.u + (param.uDiff/2); %mean of right-side negative gaussian

gauss2a = (param.scaleLeft.*(exp(-(xvals-param.uLeft).^2 / (2*(param.var.^2))))); %left-side negative Gaussian function (NB uses same var as g1p)
gauss2b = (param.scaleRight.*(exp(-(xvals-param.uRight).^2 / (2*(param.var.^2))))); %left-side negative Gaussian function

yvals = gauss1 - (gauss2a+gauss2b); %add the negative lobes to get a bimodal gaussian, then subtract the lot from the main gaussian