function [x,y] = PlotEllipse(MajRad,MinRad,theta,Xoff,Yoff);
%function [x,y] = PlotEllipse(MajRad,MinRad,Theta,Xoff,Yoff);
%
% draws an ellipse in x,y coordinates for plotting
% input Major Radius, Minor Radius, theta (in deg), X offset, Y offset
% for orientation 0=horizontal, 90=vertical
% e.g. [x,y] = PlotEllipse(2,1,90,0,0); figure; plot(x,y,'r-'); axis equal;

 t = linspace(0,2*pi,100);
 theta = deg2rad(theta);
% a=2;
% b=1;
% x0 = 0.15;
% y0 = 0.30;
 x = Xoff + MajRad*cos(t)*cos(theta) - MinRad*sin(t)*sin(theta);
 y = Yoff + MinRad*sin(t)*cos(theta) + MajRad*cos(t)*sin(theta);