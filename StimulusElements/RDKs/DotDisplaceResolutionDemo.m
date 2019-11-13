%DotDisplaceResolutionDemo
%how many distinct directions can we get with step sizes of varying
%magnitudes?

clear all;
dotStep = [1 2 3 5 10 15 20 30 45 60];

dotsXY  = zeros(360,2); %360 dots all at 0,0
dotDirs = 0:1:359;
DotNum  = numel(dotDirs);

for ss=1:numel(dotStep)
% displace dots
newdotsXY(:,1,ss) = round(dotsXY(:,1) + cos(deg2rad(dotDirs')).*dotStep(ss)); %displace X
newdotsXY(:,2,ss) = round(dotsXY(:,2) - sin(deg2rad(dotDirs')).*dotStep(ss)); %displace Y
[DotDirActual(:,ss),DotStepActual(:,ss)] = cart2pol(round(newdotsXY(:,1,ss)),round(newdotsXY(:,2,ss)));
NumDir(ss)   = numel(unique(round(rad2deg(DotDirActual(:,ss)))));
NumSteps(ss) = numel(unique(round(DotStepActual(:,ss))));
end

figure
for ss=1:numel(dotStep)
    subplot(2,ceil(numel(dotStep)/2),ss)
    plot(round(newdotsXY(:,1,ss)),round(newdotsXY(:,2,ss)),'o');
    xlim([-dotStep(ss)*2 dotStep(ss)*2]);
    ylim([-dotStep(ss)*2 dotStep(ss)*2]);
    axis square;
    title(strcat(num2str(dotStep(ss)),'pix stepsize'));
end

figure
subplot(2,2,1)
h=plot(dotDirs,round(rad2deg(DotDirActual)),'o-');
axis square;
legend(h,num2str(dotStep'));
xlabel('Requested direction');
ylabel('Presented direction');
title('Directions');

subplot(2,2,2)
plot(dotDirs,DotStepActual,'o-');
xlabel('Requested direction');
ylabel('Presented step size');
axis square;

subplot(2,2,3);
bar(dotStep,NumDir)
xlabel('Step Size (pix');
ylabel('Num Unique Directions');
axis square;

subplot(2,2,4);
bar(dotStep,NumSteps)
xlabel('Step Size (pix');
ylabel('Num Unique Step Sizes');
axis square;