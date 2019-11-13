%CurvefitDemoWH
%plot all 4 subjects' data in separate subplots
clear all

data = [   -1.0000         0   40.0000;
    -0.8000         0   40.0000;
    -0.6000         0   40.0000;
    -0.4000    0.0500   40.0000;
    -0.2000    0.0250   40.0000;
    0    0.3250   40.0000;
    0.2000    0.6750   40.0000;
    0.4000    0.8500   40.0000;
    0.6000    0.9750   40.0000;
    0.8000    1.0000   40.0000;
    1.0000    1.0000   40.0000];

%% curve fitting parameters
sigmoid='cumulative gaussian';      %Specify which function for curve fit.
% sigmoid='logistic';
% sigmoid='weibull';
% sigmoid='gumbel';
% sigmoid='linear';

ci=68;      %Percentage width of confidence intervals.
switch ci
    case 95
        limits=[0.025 0.975];
    case 68
        limits=[0.16 0.84];
end
curveOpts = {
    'PLOT_OPT' 'no plot' % 'plot without stats'
    'verbose' 'false'
    'N_INTERVALS' 1
    'RUNS' 0
    'SHAPE' sigmoid
    'CUTS' [0.25 0.5 0.75] %take threshold at midpoint only
    'conf' limits}'; %note transposed
%    'GAMMA_LIMITS' [0,0.01]
%    'LAMBDA_LIMITS' [0,0.01]

%% curve fitting

figure
h=plot(data(:,1),data(:,2),'ko');%
hold on
[S] = pfit(data, curveOpts{:}); %run Wichman&Hill curvefit
midpoints  = S.thresholds.est(2);
thresholds = abs(S.thresholds.est(3)-S.thresholds.est(2));
plotpf(S.shape, S.params.est,'color',[1 0 0]); %plot fitted curve
xlim([-1 1]);
xtick(-1:0.5:1)
ylim([0 1]);
ytick([0 0.25 0.5 0.75 1]);
xlabel('Position of horizontal line');
ylabel('Proportion upwards');
axis square

display(midpoints); display(thresholds);

