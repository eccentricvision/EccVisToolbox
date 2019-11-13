%FitCumuGaussDemo_Weight_vs_NonWeight.m
%demo file to compare weighted vs non-weighted fits

clear all;

%% data
%x=linspace(-5,5,17); %this is an example x-axis, e.g. between -5deg to +5deg in 17 steps
x = [4 9 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 32 33 40 41 60 100];

%PropCorr=([7 6 7 9 7 13 23 17 20 22 34 37 39 44 41 49 48])./50; %this is 2AFC data, scored as e.g. proportion 'counterclockwise' (as if there were 50 trials)
RespCorr   = [0     1     2     1     2     1     0     2     1     1     2     1     3     4     5     1     2     2     1     2     2     1     1     1     1     1     1];
NumTrials  = [1     1     3     1     2     3     2     3     4     3     6     5     6     4     5     1     2     2     1     2     2     1     1     1     1     1     1];
PropCorr   = RespCorr./NumTrials;

%% generate some smoothed data for comparison
bc = [1/3 1/3 1/3]; %the boxcar to take the running average
SmoothProp = conv(PropCorr,bc,'same');
 
%% now we fit the curves
%for normal fits -
%use: FitCumuGaussian(x-axis,prop correct,no. of trials,base of the curve,maxKP,WhichFitParams,cuts,fb)
%base of the curve = where the curve hits bottom - could be chance or could
%be zero (so for a proportion clockwise or proportion left scoring system
%you set this to zero. for proportion correct you set the base to chance e.g. 0.5 for 2AFC)
%maxKP = the maximum key press error rate (proportion e.g. 0.05) - if you want the curve always to go to 100% then input zero
%WhichFitParams = which parameters to fit (0 or 1) - mean, variance, kp. just put [1 1 1] if you want all 3 parameters
%cuts = specific performance points to report. I put [0.25 0.5 0.75] for a curve from 0-100% because i take the threshold as the x-axis point with 75% - 50%
%fb = whether the psychometric function is forwards or backwards

%for weighted fits -
%[uEst,varEst,kpEst,cutEst,fb] = FitCumuGaussianWeighted(x-axis,prop correct,no. of trials,base of the curve,maxKP,WhichFitParams,cuts,fb)
%inputs ond outputs are the same but make sure the 'no. of trials' input is a vector with varying number of trials e.g. [2 3 6 4 3 ...]

%the output of both is [u,v,kp,cuts,fb] = u is mean, v is variance, kp is keypress errors, fb = 1 or -1 where 1=forwards (ie ascending) and -1 is backwards

%fit the curves
base     = 0.25; %chance level for 4afc data
threshpt = 0.625; %threshold point for 4afc data

[u,v,kp,cuts,fb]      = FitCumuGaussian(x,PropCorr,round(mean(NumTrials)),base,0.05,[1 1 1],[],threshpt); %normal curve fit
[u2,v2,kp2,cuts2,fb2] = FitCumuGaussianWeighted(x,PropCorr,NumTrials,base,0.05,[1 1 1],[],threshpt); %weighted curve fit

%% now draw the curves

xfine=linspace(min(x(:)),max(x(:)),1000); %make a finer representation of the xaxis

probfit  = DrawCumuGaussian(xfine,u,v,kp,base,fb); %draw the normal curve - here you input the finer xaxis, and 5 values - [u=mean v=variance kp=keypress base=base of the curve, fb=forwards/backwards ];
probfit2 = DrawCumuGaussian(xfine,u2,v2,kp2,base,fb2); %draw the weighted curve

figure
for pp=1:numel(x) %plot points one-by-one with adjusted sizes
    h(1)=plot(x(pp),PropCorr(pp),'ro','MarkerFaceColor',[1 0 0],'MarkerSize',4+NumTrials(pp)); %plot data with size adjusted values
    hold on;
end
h(2)=plot(x(2:end-1),SmoothProp(2:end-1),'r--'); %plot smoothed data for comparison

h(3)=plot(xfine,probfit,'b-'); %then plot ordinary fit
h(4)=plot(xfine,probfit2,'k--'); %then weighted fit

legend(h,{'Data','Smoothed data','Normal fit','Weighted fit'});
xlabel('Intensity');
ylabel('Proportion Correct');

%report threshold values to the workspace
disp('*******');
disp(strcat('Unweighted fit threshold is: ',num2str(cuts)));
disp(strcat('Weighted fit threshold is: ',num2str(cuts2)));
disp('*******');

