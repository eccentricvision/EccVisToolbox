% FitGaussDemo
% fits and draws a Gaussian function to some made-up data
%
% made by J Greenwood 2009
% modified to use the new lsqcurvefit function October 2015

x     = -45:15:45; %x-axis for the data
xFine = -45:0.1:45; %x-axis for drawing the gaussian curve (needs a finer scale)
prop  = [0.1 0 0.4 0.9 0.3 0.1 0]; %some example data in the form of probabilities (works best for the function, though any data should be able to be sent to it)

[uE,vE,sE,oE,err1]=FitGaussian(x,prop,[-Inf 0 -Inf -Inf],[Inf Inf Inf Inf]);%,[1 1 1 1]); %fit the Gaussian with all parameters turned on to fit ([1 1 1 1] - zeros mean 'do not fit')
%four values returned are the mean (uE), variance (vE), scale(sE, which is the difference between the base value and the peak value in height), and offset (oE) which is the value of the base on the y-axis

prob2=DrawGaussian(xFine,uE,vE,sE,oE); %draw the Gaussian function using the parameters we just obtained but with the finer x-axis to get a smooth curve

lse = sum(err1.^2); %compute least square error of the fit

figure;
plot(x,prop,'o',xFine,prob2,'-'); %plot it all
