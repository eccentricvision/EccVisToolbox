function ImEll = DrawEllipseWithFringe(xRad,yRad,fringe,px,py)
% function to draw a simple ellipse (or circle) with a contrast 'fringe' or
% ramp surrounding it. Background will be 0, ellipse 1, fringe is 0-1.
%
% Ellipse(xRad,yRad) creates an Ellipse with horizontal axis == ceil(2*xRad) and vertical axis == ceil(2*yRad)
% fringe is a value in pixels added to the surround on all sides (e.g. 20 will add 20 pixels around the ellipse with decreasing contrast)
% px/py are patch dimensions

% Based on code by DN 2008, modified by JG April 2021
%e.g. im = DrawEllipseWithFringe(300,150,50,800,800); imshow(im);
% or  im = DrawEllipseWithFringe(100,150,25,800,800); imshow(im);

if nargin < 2
    yRad = xRad;
end
if nargin < 4
    px = xRad;
    py = yRad;
end
    
xRad       = xRad + .5;                     % to produce a Ellipse with horizontal axis == ceil(2*hor semi axis)
yRad       = yRad + .5;                     % to produce a Ellipse with vertical axis == ceil(2*vert semi axis)

halfpx = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy = round(py/2)-0.5;
[x,y]  = meshgrid(-halfpx:halfpx,-halfpy:halfpy);

%fringe vals
FringeVals = linspace(1,0,fringe+2); %the fringe for length
FringeVals = FringeVals(1:end-1); %crop off 0 val (no use)

%progressively draw the fringe (outside to inside)
ImEll = zeros(py,px);
for f = numel(FringeVals):-1:1
    ImTemp       = abs(x./(xRad+f)).^2 + abs(y./(yRad+f)).^2  < 1;%Line(X>-HalfLen & X<HalfLen & Y>-HalfWid & Y<HalfWid) = 1;
    ImInd        = (ImTemp==1);
    ImEll(ImInd) = FringeVals(f);
end
%now draw the main ellipse
ImTemp       = abs(x./xRad).^2 + abs(y./yRad).^2  < 1;
ImInd        = (ImTemp==1);
ImEll(ImInd) = 1;

ImEll = MaxMin(ImEll,0,1); %normalise to 0-1
