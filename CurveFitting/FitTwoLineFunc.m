function [m,b,slopeEnd,err1] = FitTwoLineFunc(x,y)
% function [m,b,slopeEnd,err1] = FitTwoLineFunc(x,y)
% Fits a two-line function with a slope first and then a flat line to the passed (x,y) data
% minval/maxvals are min and max y vals;
% slopeEnd = pt on x-axis where min/max is reached
% Similar to that proposed by Pelli et al (2004) JOV, but closer to that used by some others eg Yeshurun & Rashal (2010)
% eg. x=[1:10]; y=[8.62 6.43 5.51 4.47 3.49 3.13 1.67 0.95 1.08 1.01]; [m,b,slopeEnd,err1] = FitTwoLineFunc(x,y);x2 = [min(x):0.001:max(x)]; y2 = DrawTwoLineFunc(x2,m,b,slopeEnd); plot(x,y,'ro',x2,y2,'b-');
% or: x=[1:10]; y=[1.67 3.13 3.49 4.46 5.52 7.01 8.21 8.00 8.41 7.98]; [m,b,slopeEnd,err1] = FitTwoLineFunc(x,y);x2 = [min(x):0.001:max(x)]; y2 = DrawTwoLineFunc(x2,m,b,slopeEnd); plot(x,y,'ro',x2,y2,'b-');

% J Greenwood 2012
%x = round(x*100)./100;
% Sets up an initial guess for the three parameters
%bGuess   = 0;%min(y); %0;
tolrange = 0.2*range(y); %the range to allow before noticing a downward/upward trend in guess parameters from the flat end region
tempmin  = find(y>min(y)+tolrange);
tempmax  = find(y<max(y)-tolrange);
if y(1)>y(end) %then have a downward slope
    slopeEndGuess        = x(tempmin(end));
    %maxptGuess           = x(tempmax(1));
    %mGuess               = -1;
else %likely an upward slope
    %mGuess        = 1;
    %minptGuess    = x(tempmin(1));
    slopeEndGuess = x(tempmax(end));
end
[mGuess,bGuess,err1] = FitLine(x(1:find(x==slopeEndGuess)),y(1:find(x==slopeEndGuess))); %fit a line to the sloped part for initial guess

guess1=[mGuess bGuess slopeEndGuess]; % Parameters that will be filled in in the absence of user-provided values

opt = optimset(optimset,'MaxFunEvals',1000);
[p,err1] = fminsearch(@gFitFun,guess1,opt,x,y); % Does the fit

m=p(1);
b=p(2);
slopeEnd =p(3);
slopeEnd(slopeEnd<x(1))=x(1); slopeEnd(slopeEnd>x(end))=x(end); %round to not allow outside values

%%
function [err1]=gFitFun(p,x,y)

m        = p(1);
b        = p(2);
slopeEnd = p(3);
slopeEnd(slopeEnd<x(1))=x(1); slopeEnd(slopeEnd>x(end))=x(end); %round to not allow outside values

x     = round(x*100);
xfine = round(min(x):1:max(x));%single(linspace(min(x),max(x),10000)); %use fine-scale for fitting as gives better function
y2 = DrawTwoLineFunc(xfine./100,m,b,slopeEnd);

for t=1:length(x)
    xf(t) = find(xfine==x(t));%find values of x-axis on the finescale
end
ycomp = y2(xf);%take only y-values from the orifinal xvals - still gives a better fit than just fitting those xvals

err1=sum((ycomp-y).^2);
