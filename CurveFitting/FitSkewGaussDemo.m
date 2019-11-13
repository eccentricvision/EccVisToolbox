% FitSkewGaussDemo
% fits and draws a skewed Gaussian function to some made-up data
% and compares the fit with a non-skewed Gaussian
%
% made by J Greenwood 2015

%% first do the bimodal fit

x     = -60:15:60; %x-axis for the data
xFine = -60:0.1:60; %x-axis for drawing the gaussian curve (needs a finer scale)
%prop  = [0 0.2 0.4 0.1 0.3 0.6 0.2 0 0]; %some example data in the form of probabilities (works best for the function, though any data should be able to be sent to it)
%prop  = [0 0.1 0.3 0.6 0.4 0.7 0.4 0.2 0]; %closer peaks but still bimodal
prop  = [0 0.1 0.2 0.4 0.6 0.1 0 0 0]; %unimodal with a bump at one side
%prop  = [0 0.1 0.2 0.3 0.4 0.6 0.2 0.1 0]; %skewed unimodal distribution
%prop  = [0 0.2 0.2 0.4 0.6 0.2 0.1 0 0]; %another skewed unimodal fit

[uE,LvE,RvE,sE,oE,errSkew]=FitSkewGaussian(x,prop,[-Inf 0 0 -Inf -Inf],[Inf Inf Inf Inf Inf]);%fit the skewed Gaussian
%5 values returned are the mean, variance for the left (LvE) and right (RvE) sides of the curve, scale (sE, which is the difference between the base value and the peak value in height), 
%and offset (oE) which is the value of the base on the y-axis.

prop2=DrawSkewGaussian(xFine,uE,LvE,RvE,sE,oE); %draw the skewed Gaussian function using the parameters we just obtained but with the finer x-axis to get a smooth curve

% figure;
% plot(x,prop,'bo',xFine,prop2,'r-'); %plot it all

%% now do a regular gaussian fit 

[uGF,vGF,sGF,oGF,errGF]=FitGaussian(x,prop,[-Inf 0 -Inf -Inf],[Inf Inf Inf Inf]);%fit a regular gaussian

prop3=DrawGaussian(xFine,uGF,vGF,sGF,oGF); %draw the Gaussian function using the parameters we just obtained but with the finer x-axis to get a smooth curve

%% compare the least-squared error for the two fits

LSE = [sum((errSkew(:)).^2) sum((errGF(:)).^2)];
numParams = [6 4];
for ff = 1:2
   [AIC(ff),AICc(ff)] = ComputeAIC(LSE(ff),numel(x),numParams(ff));
end

figure;
subplot(1,3,1)
plot(x,prop,'bo',xFine,prop2,'r-',xFine,prop3,'g--');

subplot(1,3,2)
bar([1 2],LSE);
xtick({'Skew Gauss','Reg. Gauss'})
ylabel('LSE');
title('Least square error (lower=better)');

subplot(1,3,3);
bar([1 2],AIC);
xtick({'Skew Gauss','Reg. Gauss'})
ylabel('AICc');
title('Corrected Akaike Information Criterion (lower=better)');

