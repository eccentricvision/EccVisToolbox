function y = DrawThreeLineFunc(x,minval,maxval,minpt,maxpt)
% function y = DrawThreeLineFunc(x,min,max,minpt,maxpt)
% Draw a three-line function with flat minimum and maximum and a sloped line inbetween
% minval/maxvals are min and max y vals; minpt = pt on x-axis where minimum is reached, likewise maxpt
% Similar to that proposed by Pelli et al (2004) JOV - good for crowding data
% eg. x=[1:10]; y=[5.62 5.43 5.51 4.47 3.49 3.13 1.67 0.95 1.08 1.01]; x2 = [min(x):0.001:max(x)]; y2 = DrawThreeLineFunc(x2,1,5.5,7.5,3.25); plot(x,y,'ro',x2,y2,'b-');
% or: x=[1:10]; y=[1.01 1.08 0.95 1.67 3.13 3.49 4.47 5.51 5.43 5.62]; x2 = [min(x):0.001:max(x)]; y2 = DrawThreeLineFunc(x2,1,5.5,3.25,7.5); plot(x,y,'ro',x2,y2,'b-');
%
% J Greenwood 2011

if minpt<maxpt %ie positive m values (upwards sloping)
    xlo = find(x<minpt); %indices for xmin values
    y(xlo) = minval;
    xhi = find(x>maxpt); %indices for xmax value
    y(xhi) = maxval;
    xmid = find((x>=minpt)&(x<=maxpt)); %indices for middle sloped region
    y(xmid) = linspace(minval,maxval,length(xmid));
else %negative m value - downwards sloping
    xlo = find(x>minpt); %indices for xmin values
    y(xlo) = minval;
    xhi = find(x<maxpt); %indices for xmax value
    y(xhi) = maxval;
    xmid = find((x<=minpt)&(x>=maxpt)); %indices for middle sloped region
    y(xmid) = linspace(maxval,minval,length(xmid));
end
