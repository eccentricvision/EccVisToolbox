%FitCumuGaussDemo
%demo file to use John's magical psychometric function curve fits
%fits a cumulative gaussian function to specified data, returns values like
%PSE/midpoint and threshold, keypress error rate, plus 'cuts' at any
%arbitrary x-axis location for a specified performance level (e.g. 93%)
%J Greenwood v3.0 April 2018

x=linspace(-5,5,17); %this is an example x-axis, e.g. between -5deg to +5deg in 17 steps

prob=([7 6 7 9 7 13 23 17 20 22 34 37 39 44 41 49 48])./50; %this is 2AFC data, scored as e.g. proportion 'counterclockwise' (as if there were 50 trials)

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

%fit the curve
base =0;
[u,v,kp,cuts,fb,fiterror] = FitCumuGaussian(x,prob,50,base,0.05,[1 1 1],[],[0.25 0.5 0.75],1); 

%now draw the curve

xfine=linspace(-5,5,1000); %make a finer representation of the xaxis

probfit=DrawCumuGaussian(xfine,u,v,kp,base,fb); %here you input the finer xaxis, and 5 values - [u=mean v=variance kp=keypress base=base of the curve, fb=forwards ];

plot(x,prob,'ro',xfine,probfit,'b-'); %then plot it

PSE = cuts(2); %we set this as the 50% point
threshold = abs(cuts(3)-cuts(2)); %threshold is the x-axis shift required to go from 50 to 75% (in a 2AFC %left task)

disp(strcat('PSE is:',num2str(PSE)));
disp(strcat('Threshold is: ',num2str(threshold)));
