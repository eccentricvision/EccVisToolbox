function [param,err1] = FitDoBiGaussian(xvals,yvals,minparams,maxparams)
% function [param,err1] = FitDoBiGaussian(xvals,yvals,minparams,maxparams)
%
% Fits a Difference of Bimodal Gaussians ("DoBiG") function to the passed data.
% Requires the optimization toolbox.
% Fits seven parameters: 4 for the central/main excitatory gaussian, and
% 3 for the two negative lobes on either side
% Now returned in a single structure called param
%
% The first Gaussian 4 parameters - param.u = mean, param.var = variance,
% param.scale1 = peak height, param.offset = baseline offset
% (i.e. zero point of the middle curve)
%
% Second Gaussian has 3 parameters - param.uDiff = difference between the means of the two
% component gaussians (centred on param.u), param.scaleLeft = peak height of
% left-side negative gaussian, likewise for param.scaleRight
% (note second negative gaussians use same variance, offset and overall mean
% as the first gaussian - to reduce parameters)
%
% Parameters are returned in one structure, plus the residual error of the fit to the data (for each x-axis position)
%
% Now need to specify the minimum and maximum value for each parameter (which can be -Inf / Inf or 0 / Inf etc)
% Do so in order of definition: u,var,scale1,offset,uDiff,scaleLeft,scaleRight (so 7 numbers for both minparams and maxparams)
%
% J Greenwood March 2016, based on old code that is now FitDoBiGaussian_old
%
% eg1. x=[-56:8:56];prob=[0 0.1 0 -0.2 -0.4 0 0.4 0.9 0.3 0 -0.3 -0.15 0.1 0 0]; [param,err1]=FitDoBiGaussian(x,prob,[-Inf 0 -Inf -Inf 0 -Inf -Inf],[Inf Inf Inf Inf Inf Inf Inf]); xFine=[-56:0.1:56]; prob2=DrawDoBiGaussian(xFine,param);plot(x,prob,'o',xFine,prob2,'-');

% Set up an initial guess for the 7 parameters
guess.offset = min([yvals(1) yvals(end)]); %take the first and last points as guess for the base offset
midX         = find(xvals==median(xvals)); %find the middle of the x-range
rangeX       = round(numel(xvals)/4); %take the middle 1/3 of the range
yvals2       = yvals;
yvals2(1:midX-(rangeX+1))   = min(yvals(midX-rangeX:midX+rangeX)); %flatten out the negative lobe on the LHS
yvals2(midX+(rangeX+1):end) = min(yvals(midX-rangeX:midX+rangeX)); %flatten out the negative lobes on the other side

[guess.u,guess.var,guess.scale1,~,~]=FitGaussian(xvals,yvals2,[-Inf 0 -Inf -Inf],[Inf Inf Inf Inf]); %fit a gaussian to the central peak to get some guess parameters

%now work out the LHS lobe
leftxvals              = xvals(1:midX-(rangeX/2));%(xvals<guess.u); %likely values of the left negative lobe
leftyvals              = yvals(1:midX-(rangeX/2));%(xvals<guess.u)-guess.offset; %corresponding y values

guess.u2left     = leftxvals(leftyvals==min(leftyvals)); %guess is the minimum value
guess.scale2left = range(leftyvals); %scale is likely the range of values

%and the RHS lobe
rightxvals             = xvals(midX+(rangeX/2):end);%(xvals>guess.u); %likely values of the right negative lobe
rightyvals             = yvals(midX+(rangeX/2):end);%(xvals>guess.u)-guess.offset; %corresponding y values

guess.u2right     = rightxvals(rightyvals==min(rightyvals)); %find the min
guess.scale2right = range(rightyvals); %use the range as a guess
guess.uDiff       = 2*(mean(abs([guess.u2left-guess.u guess.u2right-guess.u]))); %guess for uDiff value (based on twice estimated u2 values

%now clip the range of guess parameters to reasonable values
if guess.u<min(xvals) %mean can't be outside range
    guess.u = min(xvals);
end
if guess.u>max(xvals)
    guess.u = max(xvals);
end
if guess.var>(range(xvals)/4) %can't have too huge a variance or the curve fit is meaningless
    guess.var=(range(xvals)/4);
end
if guess.scale1>(1.5*range(yvals)); %scale of curvefit shouldn't exceed stimulus range by too much
    guess.scale1=(1.5*range(yvals));
end
if guess.uDiff>(range(xvals))
    guess.uDiff=range(xvals); %can't have lobes off the scale
end
if guess.uDiff>(guess.var*8) %need to make this restriction to avoid bumpy curves where side lobes are taken from a narrow centre
    guess.uDiff=(guess.var*8);
end
if guess.uDiff<0
    guess.uDiff=0;
end
if guess.scale2left>(1.5*range(yvals)); %scale of curvefit shouldn't exceed stimulus range by too much
    guess.scale2left=(1.5*range(yvals));
end
if guess.scale2right>(1.5*range(yvals)); %scale of curvefit shouldn't exceed stimulus range by too much
    guess.scale2right=(1.5*range(yvals));
end

guess1=[guess.u guess.var guess.scale1 guess.offset guess.uDiff guess.scale2left guess.scale2right]; % Default parameters for fit - can't be in a structure for lsqcurvefit

if ~exist('minparams') %if haven't specified minimum parameter values do so here - in order: u,var,scale1,offset,uDiff,scaleLeft,scaleRight
    minparams = [-Inf 0 -Inf -Inf 0 -Inf -Inf]; %default is just to make sure variance and uDiff aren't negative
end
if ~exist('maxparams')
    maxparams = [Inf Inf Inf Inf Inf Inf Inf]; %default is no upper bounds
end

opt = optimset(optimset,'MaxFunEvals',1000,'Display','off'); %options for the fit

% Actually do the fit
[estParams,~,err1] = lsqcurvefit(@gFitFun,guess1,xvals,yvals,minparams,maxparams,opt);

%now return the final parameters
param.u          = estParams(1);
param.var        = estParams(2); 
param.scale1     = estParams(3); 
param.offset     = estParams(4);
param.uDiff      = estParams(5);
param.scaleLeft  = estParams(6); 
param.scaleRight = estParams(7); 


%%
function yfit=gFitFun(pIn,x) %here's the actual fitting stuff

p.u       = pIn(1);
p.var     = pIn(2); 
p.scale1  = pIn(3); 
p.offset  = pIn(4);
p.uDiff   = pIn(5);
p.sLeft   = pIn(6); 
p.sRight  = pIn(7); 

%restrict range of parameters (have to do this one here since it depends on the current variance value)
if p.uDiff>(p.var*7)%need to make this restriction to avoid bumpy curves where side lobes are taken from a narrow centre
    p.uDiff=(p.var*7);
end

gauss1     = (p.scale1.*(exp(-(x-p.u).^2 / (2*(p.var.^2)))))+p.offset; %positive Gaussian function

p.uLeft  = p.u - (p.uDiff/2); %set the mean of the left-side negative gaussian
p.uRight = p.u + (p.uDiff/2); %mean of right-side negative gaussian

gauss2a = (p.sLeft.*(exp(-(x-p.uLeft).^2 / (2*(p.var.^2))))); %left-side negative Gaussian function (NB uses same var as g1p)
gauss2b = (p.sRight.*(exp(-(x-p.uRight).^2 / (2*(p.var.^2))))); %left-side negative Gaussian function

yfit = gauss1 - (gauss2a+gauss2b); %add the negative lobes to get a bimodal gaussian, then subtract the lot from the main gaussian

%err1=sum((yfit-data).^2); %error is automatically returned now


