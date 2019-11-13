function [dotsXY] = PlotDotsFirstFrame(numDots,maxRad)
% generates dot positions (x,y) within a circular region
% need to input number of dots, max radius (of inclusion)
%
% e.g. [dotsXY] = PlotDotsFirstFrame(1000,500); plot(dotsXY(:,2),dotsXY(:,1),'o');
% J Greenwood May 2019, v1.1 July 2019

%random X/Y to start 
dotX = rand(1,numDots)*(maxRad*2)-maxRad; %values from -maxRad:maxRad
dotY = rand(1,numDots)*(maxRad*2)-maxRad; %values from -maxRad:maxRad
%convert to polar to check within bounds
[dotAng,dotRad] = cart2pol(dotX,dotY);
dotOutInd       = find(dotRad>maxRad);
for dd=1:numel(dotOutInd)
    dotOut = 1;
   while dotOut==1
       dotX(dotOutInd(dd)) = rand(1,1)*(maxRad*2)-maxRad; %values from -maxRad:maxRad
       dotY(dotOutInd(dd)) = rand(1,1)*(maxRad*2)-maxRad; %values from -maxRad:maxRad
       [dotAng(dotOutInd(dd)),dotRad(dotOutInd(dd))] = cart2pol(dotX(dotOutInd(dd)),dotY(dotOutInd(dd)));
       dotOut                  = dotRad(dotOutInd(dd))>maxRad;
   end
end

dotsXY      = round([dotX' dotY']); %get to correct format

%failed quicker alternative: use polar plot to randomise (can lead to central clustering)
%dotRad      = rand(1,numDots).*maxRad; %random radius value to start
%dotAng      = rand(1,numDots).*359; %random angle offset from centre
%[dotX,dotY] = pol2cart(deg2rad(dotAng),dotRad); %convert to cartesian

