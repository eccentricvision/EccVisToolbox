function [newdotsXY,dotswrapped,func_exit,numdotexit] = dotDisplaceWithWrap(dotsXY,dotDirs,dotStep,isolationRad,maxRad)
% function to displace dot positions within a circular aperture and wrap any that exceed aperture dimensions
% need to input two columns of numbers as dotsXY, direction value for each dot (degrees), step size for one frame in pixels (NB not speed, just one value),
% isolation zone size (which is a circle with radius = isolationRad in pixels), then max radius of aperture
% returns [newdotsXY,dotswrapped,func_exit,numdotexit]
%
% e.g. [dotsXY] = PlotDotsFirstFrame(1000,500);[dotsXY2,dotswrapped,func_exit,numdotexit]=dotDisplaceWithWrap(dotsXY,[ones(1,500)*45 ones(1,500)*135],5,3,500); figure; subplot(1,2,1); plot(dotsXY(:,1),dotsXY(:,2),'ro',dotsXY2(:,1),dotsXY2(:,2),'go'); axis square; subplot(1,2,2); plot(dotsXY(dotswrapped,1),dotsXY(dotswrapped,2),'ro',dotsXY2(dotswrapped,1),dotsXY2(dotswrapped,2),'go'); axis square
%
% v1.1 J Greenwood July 2019
% updated wrapped since v1.0 - now wraps dot using opposite of its direction

NumDots     = length(dotsXY); %number of dots
func_exit   = 0; %how many times the function had to quit (stops crashes but need to check this report)
dotswrapped = []; %which dots were moved
numdotexit  = NaN; %where the wrap-crash occurred
maxmovecnt  = 100; %if wrapping fails after X attempts then crash the code

% displace dots
newdotsXY(:,1) = round(dotsXY(:,1) + cos(deg2rad(dotDirs')).*dotStep); %displace X
newdotsXY(:,2) = round(dotsXY(:,2) - sin(deg2rad(dotDirs')).*dotStep); %displace Y

% wrap any that exceed the aperture
%ReGenRegion = round(0.3*maxRad); %regenerate dots in opposite third of aperture when wrapping required

[dotTh,dotRad] = cart2pol(newdotsXY(:,1),newdotsXY(:,2)); %convert to polar coordinates; keep radius but discard angle
dotOutInd  = find(dotRad>maxRad); %indices of dots outside aperture

if numel(dotOutInd)>0
    for dd=1:numel(dotOutInd)
        dotOut  = 1;
        movecnt    = 0;
        while dotOut==1
            %regenerate dotRad to be on opposite side (relative to centre of aperture)
            newdotsXY(dotOutInd(dd),1) = round(dotsXY(dotOutInd(dd),1) + cos(deg2rad(dotDirs(dotOutInd(dd))+180)).*((maxRad*1.5)+(rand(1,1)*(maxRad*0.5)))); %displace X in opposite direction by diameter
            newdotsXY(dotOutInd(dd),2) = round(dotsXY(dotOutInd(dd),2) - sin(deg2rad(dotDirs(dotOutInd(dd))+180)).*((maxRad*1.5)+(rand(1,1)*(maxRad*0.5)))); %displace Y in opposite direction by diameter
            
            [dotTh(dotOutInd(dd)),dotRad(dotOutInd(dd))] = cart2pol(newdotsXY(dotOutInd(dd),1),newdotsXY(dotOutInd(dd),2)); %convert to polar coordinates; keep radius but discard angle
            while dotRad(dotOutInd(dd))>maxRad %if dot is still outside - shift it in
                newdotsXY(dotOutInd(dd),1) = round(newdotsXY(dotOutInd(dd),1) + cos(deg2rad(dotDirs(dotOutInd(dd)))).*(dotStep)); %displace X in same direction
                newdotsXY(dotOutInd(dd),2) = round(newdotsXY(dotOutInd(dd),2) - sin(deg2rad(dotDirs(dotOutInd(dd)))).*(dotStep)); %displace Y in same direction
                [dotTh(dotOutInd(dd)),dotRad(dotOutInd(dd))] = cart2pol(newdotsXY(dotOutInd(dd),1),newdotsXY(dotOutInd(dd),2)); %convert to polar coordinates; keep radius but discard angle
                movecnt = movecnt+1;
                if movecnt>(maxmovecnt/2) %give up and randomly re-generate dot position (hopefully rare)
                    newdotsXY(dotOutInd(dd),1) = rand(1,1)*(maxRad*2)-maxRad; %values from -maxRad:maxRad
                    newdotsXY(dotOutInd(dd),2) = rand(1,1)*(maxRad*2)-maxRad; %values from -maxRad:maxRad
                    [dotTh(dotOutInd(dd)),dotRad(dotOutInd(dd))] = cart2pol(newdotsXY(dotOutInd(dd),1),newdotsXY(dotOutInd(dd),2)); %convert to polar coordinates; keep radius but discard angle
                    %disp(strcat('random regen, dot',num2str(dotOutInd(dd)))); %for debugging 
                end
            end
            %dotRad(dotOutInd(dd)) = -maxRad + (round(rand(1,1).*ReGenRegion)); %place on other side of outer radius
            [newdotsXY(dotOutInd(dd),1),newdotsXY(dotOutInd(dd),2)] = pol2cart(dotTh(dotOutInd(dd)),dotRad(dotOutInd(dd))); %convert new dot pos to x/y
            
            %check new position doesn't overlap with other dots
            dotDist(:,1)        = newdotsXY(:,1)-newdotsXY(dotOutInd(dd),1); %recast all the dots relative to this dot
            dotDist(:,2)        = newdotsXY(:,2)-newdotsXY(dotOutInd(dd),2);
            [~,dotDistRad] = cart2pol(dotDist(:,1),dotDist(:,2));
            TooClose = find(dotDistRad<isolationRad); %which dots are too close to this one (NB. includes the dot itself!)
            if numel(TooClose)>1 %since always includes the dot itself at 0 dist
                dotOut=1; %need to regenerate dot position above
                if movecnt==round(maxmovecnt/2)
                    newdotsXY(dotOutInd(dd),1) = newdotsXY(dotOutInd(dd),1)+(randn(1,1)*isolationRad); %add a little jitter to try move it out of the way
                    newdotsXY(dotOutInd(dd),2) = newdotsXY(dotOutInd(dd),2)+(randn(1,1)*isolationRad);
                end
            else %no close dots - end the loop and move on
                dotOut=0;
            end
            movecnt = movecnt+1;
            if movecnt>maxmovecnt
                dotOut=1;
                func_exit = 1;
                numdotexit = dotOutInd(dd);
                break;
            end
        end
    end
end
dotswrapped = dotOutInd;

newdotsXY = round(newdotsXY); %make sure they're whole pixel values