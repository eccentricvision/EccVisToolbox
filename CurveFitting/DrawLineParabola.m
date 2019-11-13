function y = DrawLineParabola(x,m,b,s)
% function y = DrawLineParabola(x,m,b,s)
% Draw a line + parabola mix that has been fit using FitLineParabola.m
% eg. x=[1 2 3 4 5]; y=[1.8427 1.4020 1.6321 2.5056 2.3402]; [m,b,s]=FitLineParabola(x,y,[1 1 1]); x2 = [min(x):0.001:max(x)]; y2 = DrawLineParabola(x2,m,b,s); plot(x,y,'ro',x2,y2,'b-');
%
% J Greenwood 2010

y = (m.*((x-s).^2))+b;
