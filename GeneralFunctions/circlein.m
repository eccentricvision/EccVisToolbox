%circlein
%calculates whether a point is inside a circle centred on (centX,centY)
%input (centX,centY) of circle, (pointX,pointY) and desired radius
%returns inside 0/1, theta of difference and radius of difference
%e.g. inside = circlein(300,300,450,450,300)
%e.g. outside = circlein(300,300,450,450,100)

function [inside,theta,actrad] = circlein(centX,centY,pointX,pointY,desrad)

relX = pointX-centX; %define point relative to centre
relY = pointY-centY;
[theta,actrad] = cart2pol(relX,relY); %convert cartesian coordinates to polar - angle in radians and radius
if actrad > desrad %actual radius of point is outside desired radius
    inside = 0;
else
    inside = 1;
end
end