% FitBimodalGaussDemo
% fits and draws a bimodal Gaussian function to some made-up data
%
% made by J Greenwood 2015

%% first do the bimodal fit

x     = -60:15:60; %x-axis for the data
xFine = -60:0.1:60; %x-axis for drawing the gaussian curve (needs a finer scale)
prop  = [0 0.2 0.4 0.1 0.3 0.6 0.2 0 0]; %some example data in the form of probabilities (works best for the function, though any data should be able to be sent to it)
%prop  = [0 0.1 0.3 0.6 0.4 0.7 0.4 0.2 0]; %closer peaks but still bimodal
%prop  = [0 0.1 0.2 0.4 0.6 0.1 0 0 0]; %unimodal with a bump at one side
%prop  = [0 0.1 0.2 0.3 0.4 0.6 0.2 0.1 0]; %skewed unimodal distribution
%prop  = [0 0.2 0.2 0.4 0.6 0.2 0.1 0 0]; %another skewed unimodal fit

[u1E,u2E,vE,s1E,s2E,oE,lseBM]=FitBimodalGaussian(x,prop,[-Inf -Inf 0 -Inf -Inf -Inf],[Inf Inf Inf Inf Inf Inf]);%fit the bimodal Gaussian
%six values returned are the means (u1E & u2E) of each curve, variance (vE), scales (s1E & s2E, which is the difference between the base value and the peak value in height), 
%and offset (oE) which is the value of the base on the y-axis. Note variance and offset are common to both of the underlying Gaussians in thebimodal fit

prop2=DrawBimodalGaussian(xFine,u1E,u2E,vE,s1E,s2E,oE); %draw the Gaussian function using the parameters we just obtained but with the finer x-axis to get a smooth curve

% figure;
% plot(x,prop,'bo',xFine,prop2,'r-'); %plot it all

%% now do a gaussian fit 

[uGF,vGF,sGF,oGF,lseGF]=FitGaussian(x,prop,[-Inf 0 -Inf -Inf],[Inf Inf Inf Inf]);%fit a regular gaussian

prop3=DrawGaussian(xFine,uGF,vGF,sGF,oGF); %draw the Gaussian function using the parameters we just obtained but with the finer x-axis to get a smooth curve

%% compare the least-squared error for the two fits

LSE = [sum((lseBM(:)).^2) sum((lseGF(:)).^2)];
numParams = [6 4];
for ff = 1:2
   [AIC(ff),AICc(ff)] = ComputeAIC(LSE(ff),numel(x),numParams(ff));
end

figure;
subplot(1,3,1)
plot(x,prop,'bo',xFine,prop2,'r-',xFine,prop3,'g--');

subplot(1,3,2)
bar([1 2],LSE);
xtick({'Bimodal','Unimodal'})
ylabel('LSE');
title('Least square error (lower=better)');

subplot(1,3,3);
bar([1 2],AIC);
xtick({'Bimodal','Unimodal'})
ylabel('AIC');
title('Corrected Akaike Information Criterion (lower=better)');

