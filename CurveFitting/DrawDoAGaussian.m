function yvals = DrawDoAGaussian(xvals,g1p,g2p)
%function yvals = DrawDoBiGaussian(xvals,g1p,g2p);
%draws a 'difference of asymmetric gaussians' function using 2 input structures
%xvals = xaxis to draw across, g1p = structure for parameters of 1st
%(central excitatory) gaussian, g2p = structure for parameters of 2nd asymmetric gaussian that forms the inhibitory 'lobes' to either side
%
%g1p has 4 parameters - g1p.u = mean, g1p.var = variance, 
%g1p.scale = peak height, g1p.offset = baseline offset 
%(i.e. zero point of the middle curve)
%
%g2p has 3 parameters - g2p.varLeft and g2p.varRight, plus g2p.scale 
%(g2p.u and g2p.offset are constrained by the first curve)
%
%
%J Greenwood September 2015, on the orders of V Goffaux ;)
%
%e.g. xvals = 0:22.5:180; yplot = [0.76 0.37 0.30 0.96 1.22 0.82 0.56 0.61 0.76]; xFine = 0:0.1:180; g1p.u = 88.06; g1p.var = 20.4; g1p.scale=0.5; g1p.offset = 0.8;g2p.uDiff = 90;g2p.scaleLeft = 0.55;g2p.scaleRight=0.25; yvals = DrawDoBiGaussian(xFine,g1p,g2p);plot(xvals,yplot,'ro',xFine,yvals,'b-');

gauss1     = (g1p.scale.*(exp(-(xvals-g1p.u).^2 / (2*(g1p.var.^2)))))+g1p.offset; %positive Gaussian function

g2p.uLeft  = g1p.u - (g2p.uDiff/2); %set the mean of the left-side negative gaussian
g2p.uRight = g1p.u + (g2p.uDiff/2); %mean of right-side negative gaussian

gauss2a = (g2p.scale.*(exp(-(xvals-g1p.u).^2 / (2*(g1p.varLeft.^2))))); %left-side negative Gaussian function (NB uses same var as g1p)
gauss2b = (g2p.scale.*(exp(-(xvals-g1p.u).^2 / (2*(g1p.varRight.^2))))); %left-side negative Gaussian function

[~,minind]=min(abs(xvals-g1p.u)); %find the x-axis location of the mean value

gauss2 = [gauss2a(1:minind-1) mean([gauss2a(minind) gauss2b(minind)]) gauss2b(minind+1:end)]; %stitch together the negative lobe

yvals = gauss1 - gauss2; %subtract the asymmetric gaussian from the main gaussian