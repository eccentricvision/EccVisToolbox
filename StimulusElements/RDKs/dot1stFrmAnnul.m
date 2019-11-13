
function [dotsYX] = dot1stFrmAnnul(numDots,minRad,maxRad)
%gen1stFrmAnnul - J Greenwood 2009
%generates dot positions (y,x) within an annular or circular region
%need to input number of dots, minimum radius (of exclusion) and max radius (of inclusion)
%e.g. [dotsYX] = dot1stFrmAnnul(600,200,600); plot(dotsYX(:,2),dotsYX(:,1),'o');
dotsRad = (rand(numDots,1).*(maxRad-minRad))+minRad; %generate initial positions within accepted zone
dotsAng = (rand(numDots,1).*359); %random angle
[x,y] = pol2cart(DegToRad(dotsAng),dotsRad);
dotsYX = round([y x]);
