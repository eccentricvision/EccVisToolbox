function [g1p,g2p,LSerror] = FitDoAsymGaussian(xvals,yvals,WhichFit,paramVals)
% function [g1p,g2p,LSerror] = FitDoAsymGaussian(xvals,yvals,WhichFit,paramVals)
%
% Fits a Difference of Asymmetric Gaussians ("DoAsymGauss") function to the passed data.
% Requires the optimization toolbox.
% Seven parameters in two sets: 4 for the central/main excitatory gaussian,
% 3 for the two negative lobes on either side
%
% g1p has 4 parameters - g1p.u = mean, g1p.var = variance, 
% g1p.scale = peak height, g1p.offset = baseline offset 
% (i.e. zero point of the middle curve)
%
% g2p has 3 parameters - g2p.varLeft and g2p.varRight, plus g2p.scale 
% (g2p.u and g2p.offset are constrained by the first curve)
% (note second negative gaussians use same mean and offset
% as the first gaussian - to reduce parameters)
%
% parameters are returned in two chunks: g1p and g2p, also get the
% least-squares error (LSerror) from the best fit for reference
%
% If you specify the third parameter 'WhichFit' to be e.g. [0 1 1 1 1 1 1]
% the routine will fit everything except the mean of g1p
% order is g1p.u, g1p.var, g1p.scale, g1p.offset, g2p.varLeft, g2p.varRight, g2p.scale
%
% If any of the 'WhichFit' values are 0 then you specify the final parameter 'paramVals' to use for the unfitted variables
% e.g. 'FitDoAsymGaussian(inputs,prop,[0 1 1 1 1 1],90)' will fit with a fixed mean of g1p at 90
%
% J Greenwood September 2015, on the orders of V Goffaux ;)
% see FitDoAsymGFitDemo for an example

% Set up an initial guess for the 7 parameters

guess.offset = min([yvals(1) yvals(end)]); %take the first and last points as guess for the base offset
midX         = find(xvals==median(xvals));
rangeX       = round(numel(xvals)/4); %take the middle 1/4 of the range
yvals2       = yvals;
yvals2(1:midX-(rangeX+1)) = min(yvals(midX-rangeX:midX+rangeX)); %flatten out the negative lobes
yvals2(midX+(rangeX+1):end) = min(yvals(midX-rangeX:midX+rangeX));%flatten out the negative lobes
%yvals2           = yvals-guess.offset; %subtract the offset to isolate the likely central gaussian
%yvals2(yvals2<0)  = 0; %just take the central peak to fit for g1p.var1Guess and others

[guess.u,guess.var,guess.scale1,~]=FitGaussian(xvals,yvals2,[1 1 1 1]); %fit a gaussian to the central peak to get some guess parameters

negxvals      = [xvals(1:midX-rangeX) xvals(midX+rangeX:end)]; %values for the negative lobes to be fit as a separate gaussian

%need to make a full flipped LHS version and a full flipped RHS version to get guess parameters
leftyvals1  = yvals(1:midX-rangeX);%(xvals<median(xvals)); %take LHS data from likely negative lobe
leftyvals   = abs([leftyvals1 fliplr(leftyvals1)]-max(leftyvals1)); %mirror the data with flipLR then mirror on vert axis to make a normal gaussian

%leftyvals1             = leftyvals1(leftyvals1<=guess.offset); %find the actual values less than the baseline
%get the corresponding x values
% for xx=1:numel(leftyvals1)
%     leftxvalsInd(xx)   = find(yvals==leftyvals1(xx),1);
% end
% leftxvals = xvals(sort([leftxvalsInd ((numel(xvals)+1)-leftxvalsInd)]));

%now go back to correcting the yvalues
%leftyvals1             = sort(abs(leftyvals1-guess.offset),2,'ascend');
%leftyvals2             = fliplr(leftyvals1);

[~,guess.var2left,guess.scale2left,~]=FitGaussian(negxvals,leftyvals,[0 1 0 1],[median(xvals) range(leftyvals)]); %fit a gaussian to the left lobe to get some guess parameters (don't fit mean)

%now make a flipped RHS version
rightyvals2  = yvals(midX+rangeX:end);%(1:midX-rangeX);%(xvals>median(xvals)); %take LHS data from likely negative lobe
rightyvals   = abs([fliplr(rightyvals2) rightyvals2]-max(rightyvals2)); %mirror the data with flipLR then mirror on vert axis to make a normal gaussian
%rightyvals2             = rightyvals2(rightyvals2<=guess.offset); %find the actual values less than the baseline

%get the corresponding x values
%for xx=1:numel(rightyvals2)
%    rightxvalsInd(xx) = find(yvals==rightyvals2(xx),1);
%end
%rightxvals = xvals(sort([rightxvalsInd ((numel(xvals)+1)-rightxvalsInd)]));
%now go back to the y values
%rightyvals2             = sort(abs(rightyvals2-guess.offset),2,'descend');
%rightyvals1             = fliplr(leftyvals2);

[~,guess.var2right,guess.scale2right,~]=FitGaussian(negxvals,rightyvals,[0 1 0 1],[median(xvals) range(rightyvals)]); %fit a gaussian to the right lobe to get some guess parameters (don't fit variance or offset)

guess.scale2 = max([guess.scale2left guess.scale2right]);

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
if guess.var2left>(range(xvals)/4) %can't have too huge a variance or the curve fit is meaningless
    guess.var2left=(range(xvals)/4);
end
if guess.var2right>(range(xvals)/4) %can't have too huge a variance or the curve fit is meaningless
    guess.var2right=(range(xvals)/4);
end
if guess.var2left>(3*guess.var2right) %need to restrict range of variance differences
    guess.var2left=(3*guess.var2right);
end
if guess.var2right>(3*guess.var2left)
    guess.var2right=(3*guess.var2left);
end
if guess.scale2>(1.5*range(yvals)); %scale of curvefit shouldn't exceed stimulus range by too much
    guess.scale2=(1.5*range(yvals));
end

defVals=[guess.u guess.var guess.scale1 guess.offset guess.var2left guess.var2right guess.scale2]; % Default parameters for fit
fixVals=defVals; % Parameters that will be filled in in the absence of user-provided values

if ~exist('WhichFit') % If the user didn't specify which parmeters to fit...
    WhichFit=[1 1 1 1 1 1 1]; % ... then assume they want to fit everything
end

guess1=defVals(find(WhichFit)); % Initial guess for the parameters to be fit

if exist('paramVals')
    fixVals(find(~WhichFit))=paramVals; % If the user gave us some fixed parameters then slot them into fixVals
end

opt = optimset(optimset,'MaxFunEvals',100000); %options for the fit
[bestParams,LSerror] = fminsearch(@gFitFun,guess1,opt,xvals,yvals,WhichFit,fixVals); % Does the fit using the section below

% Make a list of the all the fit and fixed params
estParams=[0 0 0 0 0 0 0];
estParams(find(WhichFit))=bestParams;
estParams(find(~WhichFit))=fixVals(find(~WhichFit));

%now return the final parameters
g1p.u           = estParams(1);
g1p.var         = abs(estParams(2)); %absolute variance only
g1p.scale       = abs(estParams(3)); %absolute scale only
g1p.offset      = estParams(4); 
g2p.varLeft     = abs(estParams(5)); %absolute variance only
g2p.varRight    = abs(estParams(6)); %absolute variance only
g2p.scale       = abs(estParams(7)); %absolute scale only

%now clip the final range of parameters
if g1p.u<min(xvals) %mean can't be outside range
    g1p.u = min(xvals);
end
if g1p.u>max(xvals)
    g1p.u = max(xvals);
end
if g1p.var>(range(xvals)/4) %can't have too huge a variance or the curve fit is meaningless
    g1p.var=(range(xvals)/4);
end
if g1p.scale>(1.5*range(yvals)); %scale of curvefit shouldn't exceed stimulus range by too much
    g1p.scale=(1.5*range(yvals));
end
if g2p.varLeft>(range(xvals)/4) %can't have too huge a variance or the curve fit is meaningless
    g2p.varLeft=(range(xvals)/4);
end
if g2p.varRight>(range(xvals)/4) %can't have too huge a variance or the curve fit is meaningless
    g2p.varRight=(range(xvals)/4);
end
if g2p.varLeft>(3*g2p.varRight) %need to restrict range of variance differences
    g2p.varLeft=(3*g2p.varRight);
end
if g2p.varRight>(3*g2p.varLeft)
    g2p.varRight=(3*g2p.varLeft);
end
if g2p.scale>(1.5*range(yvals)); %scale of curvefit shouldn't exceed stimulus range by too much
    g2p.scale=(1.5*range(yvals));
end

%%
function err1=gFitFun(InParams,x,data,WhichFit,fixVals)

%here's the actual fitting stuff

p = [0 0 0 0 0 0 0];
p(find(WhichFit))=InParams;
p(find(~WhichFit))=fixVals(find(~WhichFit));

g1p.u        = p(1);
g1p.var      = abs(p(2)); %absolute variance only
g1p.scale    = abs(p(3)); %absolute scale only
g1p.offset   = p(4); 
g2p.varLeft  = abs(p(5)); %absolute variance only
g2p.varRight = abs(p(6)); %absolute variance only
g2p.scale    = abs(p(7)); %absolute scale only

%now clip the final range of parameters
if g1p.u<min(x) %mean can't be outside range
    g1p.u = min(x);
end
if g1p.u>max(x)
    g1p.u = max(x);
end
if g1p.var>(range(x)/4) %can't have too huge a variance or the curve fit is meaningless
    g1p.var=(range(x)/4);
end
if g1p.scale>(1.5*range(data)); %scale of curvefit shouldn't exceed stimulus range by too much
    g1p.scale=(1.5*range(data));
end
if g2p.varLeft>(range(x)/4) %can't have too huge a variance or the curve fit is meaningless
    g2p.varLeft=(range(x)/4);
end
if g2p.varRight>(range(x)/4) %can't have too huge a variance or the curve fit is meaningless
    g2p.varRight=(range(x)/4);
end
if g2p.varLeft>(3*g2p.varRight) %need to restrict range of variance differences
    g2p.varLeft=(3*g2p.varRight);
end
if g2p.varRight>(3*g2p.varLeft)
    g2p.varRight=(3*g2p.varLeft);
end
if g2p.scale>(1.5*range(data)); %scale of curvefit shouldn't exceed stimulus range by too much
    g2p.scale=(1.5*range(data));
end

gauss1     = (g1p.scale.*(exp(-(x-g1p.u).^2 / (2*(g1p.var.^2)))))+g1p.offset; %positive Gaussian function

gauss2a = (g2p.scale.*(exp(-(x-g1p.u).^2 / (2*(g2p.varLeft.^2))))); %left-side negative Gaussian function (NB uses same var as g1p)
gauss2b = (g2p.scale.*(exp(-(x-g1p.u).^2 / (2*(g2p.varRight.^2))))); %right-side negative Gaussian function

[~,minind]=min(abs(x-g1p.u)); %find the x-axis location of the mean value

gauss2 = [gauss2a(1:minind-1) mean([gauss2a(minind) gauss2b(minind)]) gauss2b(minind+1:end)]; %stitch together the negative lobe

yfit = gauss1 - gauss2; %subtract the asymmetric gaussian from the main gaussian

err1=sum((yfit-data).^2);
