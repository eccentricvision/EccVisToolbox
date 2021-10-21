function y = DrawParabola(x,m,b)
% function y = DrawParabola(x,m,b)
% Draw a parabola that has been fit using FitParabola.m
% needs x-axis (x) and 2 parameters: m (scale value) & b (baseline value)
% NB assumes parabola is centred on 0 with x-axis extending -ve to +ve
% otherwise need to fit the inflection point, see DrawLineParabola
% eg. x=[1 2 3 4 5]; y=[1.8427 1.4020 1.6321 2.5056 2.3402]; [m,b,s]=FitLineParabola(x,y,[1 1 1]); x2 = [min(x):0.001:max(x)]; y2 = DrawLineParabola(x2,m,b,s); plot(x,y,'ro',x2,y2,'b-');
%
% J Greenwood Oct 2021

y = (m.*((x).^2))+b;
