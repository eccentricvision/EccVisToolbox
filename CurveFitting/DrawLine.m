function y = DrawLine(x,m,b)
% function y = DrawLine(x,m,b)
% Draw a line that has been fit using FitLine.m
% eg. x=[3.38 0.81 1.61 1.60 3.70 1.48 3.92 2.75 1.08 2.12 2.08 1.92 0.82 2.26 6.53 1.48 1.11]; y=[1.57 0.79 1.15 1.18 1.45 1.44 1.80 1.69 0.83 1.36 1.45 1.04 1.08 1.27 3.46 0.79 0.93]; [m,b]=FitLine(x,y); x2 = [min(x):0.001:max(x)]; y2 = DrawLine(x2,m,b); plot(x,y,'ro',x2,y2,'b-');
%
% J Greenwood 2010

y = (m.*x)+b;
