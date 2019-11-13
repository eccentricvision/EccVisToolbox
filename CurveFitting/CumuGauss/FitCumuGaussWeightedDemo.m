%FitCumuGaussWeighted
%demo file to use John's curve fit (now with weighting)

x=linspace(-5,5,30); %this is your x-axis, e.g. between -5deg to +5deg in 17 steps

prob= [0 1 0 0 0 0 0 8 0 8 0 0 10 0 3 0 3 3 0 10 0 10 0 4 4 1 10 1 1 1]; %this is proportion correct data, e.g. proportion 'counterclockwise' (as if there were 50 trials)

trials = [1 1 1 3 1 3 8 8 8 8 10 10 10 10 3 3 3 3 1 10 1 10 1 4 4 1 10 1 1 1];
%trials = [1 1 1 3 100 3 8 8 8 8 10 10 10 10 3 3 3 3 1 10 1 10 1 4 4 1 10 1 1 1];

probcorr = prob./trials;

%now we fit the curve using [uEst,varEst,kpEst,cutEst,fb,err1] = FitCumuGaussian(xvals,propcorr,trialnum,base,maxKP,WhichFitParams,fixVals,cuts,fb)
%use: FitCumuGaussian(x-axis,prop correct,no. of trials,base of the curve (proportion),max keypress error,WhichFitParams,fixed parameter values,cuts,forwards vs backwards)
%base of the curve = where the curve hits bottom - could be chance or could be zero (so for a proportion clockwise or proportion left scoring system
%you set this to zero. for proportion correct you set the base to chance e.g. 0.5 for 2AFC)
%maxKP = the maximum key press error rate (proportion e.g. 0.05) - if you want the curve always to go to 100% then input zero
%WhichFitParams = which parameters to fit (0 or 1) - mean, variance, kp. just put [1 1 1] if you want all 3 parameters
%fixed vals need to be as many 0s as you put in WhichFitparams (ie must specify the fixed values to use if you're not fitting). If none, input []
%cuts = specific performance points to report. I put [0.25 0.5 0.75] for a curve from 0-100% because i take the threshold as the x-axis point with 75% - 50%
%fb = 1 or -1 where 1=forwards (ie ascending) and -1 is backwards
%the output is [u,v,kp,cuts,fb] = u is mean, v is variance, kp is keypress errors, fb = 1 or -1 where 1=forwards (ie ascending) and -1 is backwards

%difference from the non-weighted fits is that you need an array of trial numbers with a length that matches the proportion correct and x-axis

%fit the curve
base = 0;
paramRanges(1,:) = [min(xvals(:)) max(xvals(:))]; %potential range of u values
paramRanges(2,:) = ([min(abs(xvals(2:end)-xvals(1:end-1)))./2 range(xvals(:))].^2); %potential range of v values
paramRanges(3,:) = [0 0];
[u,v,kp,cuts,fb] = FitCumuGaussianWeighted_v5(x,probcorr,trials,base,[0.25 0.5 0.75],1,[1 1 0],0,paramRanges);  %FitCumuGaussianWeighted_v5(xvals,propcorr,trialnum,base,cuts,fb,WhichFitParams,fixVals,paramRanges)
%[u,v,kp,cuts,fb] = FitCumuGaussianWeighted(x,probcorr,trials,base,0.05,[1 1 1],[],[0.25 0.5 0.75]);

%now draw the curve

xfine=linspace(-5,5,1000); %make a finer representation of the xaxis

probfit=DrawCumuGaussian(xfine,u,v,kp,base,fb); %here you input the finer xaxis, and 5 values - [u=mean v=variance kp=keypress base=base of the curve, fb=forwards ];

plot(x,probcorr,'ro',xfine,probfit,'b-'); %then plot it
hold on;
for vv=2:numel(prob)-1
    probAv(vv-1) = mean([probcorr(vv-1) probcorr(vv) probcorr(vv+1)]); %take a running mean
end
plot(x(2:end-1),probAv,'g-');
