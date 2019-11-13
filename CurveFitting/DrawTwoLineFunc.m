function twoline = DrawTwoLineFunc(x,m,b,slopeEnd)
% function twoline = DrawTwoLineFunc(x,m,b,slopeEnd)
% Draws a two-line function with a slope first and then a flat line to the passed (x,y) data
% minval/maxvals are min and max y vals;
% slopeEnd = pt on x-axis where min/max is reached
% Similar to that proposed by Pelli et al (2004) JOV, but closer to that used by some others eg Yeshurun & Rashal (2010)
%
% e.g. x=[0.8:0.2:6]; y = [(2:0.4:10)+randn(1,21) 11.*ones(1,6)]; x2 = [min(x):0.001:max(x)]; [m,b,slopeEnd]=FitTwoLineFunc(x,y); y2 = DrawTwoLineFunc(x2,m,b,slopeEnd); plot(x,y,'ro',x2,y2,'b-');
% J Greenwood 2012

if slopeEnd>max(x)
    slopeEnd=max(x); %round to be sure the slopeEnd value is in a reasonable range
end

twoline     = (m.*x)+b;
slopeEndInd = find(x>=slopeEnd); %all the values above the slope end to flatten out
twoline(slopeEndInd) = twoline(slopeEndInd(1)).*ones(1,numel(twoline(slopeEndInd)));
