function [dotsYX] = dotWrapAnnul(dotsYX,minRad,maxRad)
%function to wrap dot positions within a circular or annular aperture
%need to input two rows of numbers as dotsYX, then max dimensions of aperture
% eg. [dotsYX] = dot1stFrmAnnul(600,200,600); dotsYX=dotsYX+110; [dotsYX2]=dotWrapAnnul(dotsYX,200,600); plot(dotsYX(:,2),dotsYX(:,1),'ro',dotsYX2(:,2),dotsYX2(:,1),'go');
% J Greenwood 2009

NumDots = length(dotsYX); %number of dots
ReGenRegion = round(minRad+(0.3*maxRad)); %regenerate dots in opposite third of aperture
[dotTh,dotRad] = cart2pol(dotsYX(:,2),dotsYX(:,1)); %convert to polar coordinates; keep angle but replace radius
dotRad(dotTh<0) = -dotRad(dotTh<0); %gives -ve radius values
dotTh(dotTh<0) = dotTh(dotTh<0)+(pi); %adjusts for -ve radius vals
for dd = 1:NumDots
    wrapOK = 0; %checker for dotwrapping
    while ~wrapOK %need a full loop to check wraps before continuing - catches any dodgy re-plots
        if dotRad(dd)>0 % diff rules for +ve and -ve radii
            if dotRad(dd) < minRad %dot has moved inside central annulus (if present)
                dotRad(dd) = -minRad - (round(rand(1,1).*ReGenRegion)); %place on other side of inner radius (if present)
            elseif dotRad(dd) > maxRad %dot has moved outside maximal annulus dimensions
                dotRad(dd) = -maxRad + (round(rand(1,1).*ReGenRegion)); %place on other side of outer radius
            else %no wrap
                wrapOK=1;
            end
        else %-ve radius values
            if dotRad(dd) > -minRad %dot moved inside central annulus (if present)
                dotRad(dd) = minRad + (round(rand(1,1).*ReGenRegion)); %place on other side of inner radius (if present)
            elseif dotRad(dd) < -maxRad %dot has moved outside maximum annulus dimensions
                dotRad(dd) = maxRad - (round(rand(1,1).*ReGenRegion));
            else %no wraps
                wrapOK=1;
            end
        end
    end
end
[x,y] = pol2cart(dotTh,dotRad); %convert back to cartesian coordinates
dotsYX = round([y x]);