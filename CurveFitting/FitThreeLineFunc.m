function [minval,maxval,minpt,maxpt,err1] = FitThreeLineFunc(x,y)
% function [minval,maxval,minpt,maxpt,err1] = FitThreeLineFunc(x,y)
% Fits a three-line function with flat minimum and maximum and a sloped line inbetween to the passed (x,y) data
% minval/maxvals are min and max y vals; minpt = pt on x-axis where minimum is reached, likewise maxpt
% Similar to that proposed by Pelli et al (2004) JOV - good for crowding data
% eg. x=[1:10]; y=[5.62 5.43 5.51 4.47 3.49 3.13 1.67 0.95 1.08 1.01]; [minval,maxval,minpt,maxpt,err1] = FitThreeLineFunc(x,y);x2 = [min(x):0.001:max(x)]; y2 = DrawThreeLineFunc(x2,minval,maxval,minpt,maxpt); plot(x,y,'ro',x2,y2,'b-');
% or: x=[1:10]; y=[1.01 1.08 0.95 1.67 3.13 3.49 4.47 5.51 5.43 5.62]; [minval,maxval,minpt,maxpt,err1] = FitThreeLineFunc(x,y);x2 = [min(x):0.001:max(x)]; y2 = DrawThreeLineFunc(x2,minval,maxval,minpt,maxpt); plot(x,y,'ro',x2,y2,'b-');
%
% J Greenwood 2011

% Sets up an initial guess for the 4 parameters
minvGuess  = min(y);
maxvGuess  = max(y);
tolrange = 0.2*range(y); %10% range to allow before noticing a downward/upward trend in guess parameters
tempmin    = find(y>min(y)+tolrange);
tempmax    = find(y<max(y)-tolrange);
if y(1)>y(end) %then have a downward slope
    minptGuess = x(tempmin(end));
    maxptGuess = x(tempmax(1));
else %likely an upward slope
    %     tempmin    = find(y>min(y)+tolrange);
    %     tempmax    = find(y<max(y)-tolrange);
    minptGuess = x(tempmin(1));
    maxptGuess = x(tempmax(end));
end

guess1=[minvGuess maxvGuess minptGuess maxptGuess]; % Parameters that will be filled in in the absence of user-provided values

opt = optimset(optimset,'MaxFunEvals',1000);
[p,err1] = fminsearch(@gFitFun,guess1,opt,x,y); % Does the fit

minval=p(1);
maxval=p(2);
minpt =p(3);
minpt(minpt<x(1))=x(1); minpt(minpt>x(end))=x(end); %round to not allow outside values
maxpt =p(4);
maxpt(maxpt<x(1))=x(1); maxpt(maxpt>x(end))=x(end); %round to not allow outside values

%%
function [err1]=gFitFun(p,x,y)

minval=p(1);
maxval=p(2);
minpt =p(3);
minpt(minpt<x(1))=x(1); minpt(minpt>x(end))=x(end); %round to not allow outside values
maxpt =p(4);
maxpt(maxpt<x(1))=x(1); maxpt(maxpt>x(end))=x(end); %round to not allow outside values

x     = single(x);
xfine = single(min(x):0.01:max(x)); %use fine-scale for fitting as gives better function

y2 = DrawThreeLineFunc(xfine,minval,maxval,minpt,maxpt);

for t=1:length(x)
    xf(t) = find(xfine==x(t));%find values of x-axis on the finescale
end
ycomp = y2(xf);%take only y-values from the orifinal xvals - still gives a better fit than just fitting those xvals

err1=sum((ycomp-y).^2);
