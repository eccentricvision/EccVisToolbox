function [dotsYX] = dotWrapSquare(dotsYX,xmin,xmax,ymin,ymax)
%function to wrap dot positions within a square aperture
%need to input two rows of numbers as dotsYX, then max dimensions of aperture
% eg. DotsYX1 = round(([rand(100,1) rand(100,1)]*400) - (200)); [DotsYX2] = dotWrapSquare(DotsYX1,-150,150,-150,150);
% J Greenwood 2009

NumDots = length(dotsYX); %number of dots
ReGenRegion = round((xmax-xmin)/3); %regenerate dots in opposite third of aperture
for dd = 1:NumDots
    if dotsYX(dd,1) < xmin %check for outlier dots on x-axis
        dotsYX(dd,1) = xmax-(round(rand(1,1)*ReGenRegion)); %regenerate in opposite third
    elseif dotsYX(dd,1) > xmax
        dotsYX(dd,1) = xmin+(round(rand(1,1)*ReGenRegion));
    end

    if dotsYX(dd,2) < ymin %check for outlier dots on y-axis
        dotsYX(dd,2) = ymax-(round(rand(1,1)*ReGenRegion)); %regenerate in opposite third
    elseif dotsYX(dd,2) > ymax
        dotsYX(dd,2) = ymin+(round(rand(1,1)*ReGenRegion));
    end
end
