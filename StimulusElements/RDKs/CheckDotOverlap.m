function [newdotsXY,dotsmoved,func_exit,numdotexit] = CheckDotOverlap(dotsXY,isolationRad,maxRad)
% function to check for overlapping dot positions, with re-plotting in a circular aperture
% need to input XYmatrix (in values of ±maxRad around 0) as two columns, isolation zone size (which is a circle with radius = isolationRad in pixels),
% and size of overall circular aperture
%
% eg. [dotsXY] = PlotDotsFirstFrame(1000,500);[dotsXY2,dotsmoved,func_exit,numdotexit]=CheckDotOverlap(dotsXY,5,500); figure; subplot(1,3,1); plot(dotsXY(:,1),dotsXY(:,2),'ro'); axis square; subplot(1,3,2); plot(dotsXY2(:,1),dotsXY2(:,2),'go'); axis square; subplot(1,3,3); plot(dotsXY(:,1),dotsXY(:,2),'ro',dotsXY2(:,1),dotsXY2(:,2),'go'); axis square
% J Greenwood May 2019

NumDots    = length(dotsXY); %number of dots
func_exit  = 0; %how many times the function had to quit (stops crashes but need to check this report)
dotsmoved  = []; %which dots were moved
numdotexit = NaN;
movecnt    = 0;

%first make an image of all current locations + possible holes, including isolation zones
[meshpx,meshpy] = meshgrid(-maxRad:maxRad,-maxRad:maxRad); %coordinates for rectangle
[~,apMesh]=cart2pol(meshpx,meshpy); %convert to polar coordinates
%now make the image but first mask out the above parts outside the aperture
DotIm = zeros((maxRad*2)+1,(maxRad*2)+1);
dotsXY(dotsXY>=maxRad)=maxRad;
dotsXY(dotsXY<=-maxRad)=-maxRad; %check values at first to avoid any out-of-bounds errors
for dd=1:NumDots
    DotIm(dotsXY(dd,1)+maxRad,dotsXY(dd,2)+maxRad) = 1; %mark all the dot centres
end
IsolationZone = DrawCirc(isolationRad,[0 360],isolationRad*2,isolationRad*2); %draw one isolation zone
DotIm = conv2(DotIm,IsolationZone,'same'); %make an image with all the isolation zones overlapping
DotIm(apMesh>(maxRad))=1; %finally, remove the parts outside the aperture (NB do this after convolution to avoid edge effects)
%make a meshgrid to make sure replotted dots are within maxRad

%now replot the dots in the available spaces
for dd = 1:NumDots
    dotDist(:,1)        = dotsXY(:,1)-dotsXY(dd,1); %recast all the dots relative to this dot
    dotDist(:,2)        = dotsXY(:,2)-dotsXY(dd,2);
    [~,dotDistRad] = cart2pol(dotDist(:,1),dotDist(:,2));
    TooClose = find(dotDistRad<isolationRad); %which dots are too close to this one (NB. includes the dot itself!)
    if numel(TooClose)>1 %since always includes the dot itself at 0 dist
        for oo=2:numel(TooClose)
            if TooClose(oo)==dd
                %don't replot identity dot
            else
                movecnt=movecnt+1; %we're moving this dot
                possLoc=find(DotIm==0); %find all possible values (holes in the DotIm where dot location + isolation zones don't overlap)
                if numel(possLoc)<1
                    disp('Dot overlap error! No possible spaces remain to avoid clustering of dots!!');
                    func_exit    = 1;
                    spaceremains = 0;
                    numdotexit   = dd; %where did the exit occur
                    newdotsXY = round(dotsXY); %then quit
                    return;
                else
                    WhereToGo = ceil(rand(1,1).*numel(possLoc)); %pick one of the random locations
                    dotsXY(TooClose(oo),:) = [meshpx(possLoc(WhereToGo)) meshpy(possLoc(WhereToGo))]; %replot selected dot
                    dotsmoved(movecnt) = TooClose(oo); %report back which dots were moved
                end
            end
        end
        dotsXY = round(MaxMin(dotsXY,-maxRad,maxRad));
        %now re-make the dot image
        %now make the image but first mask out the above parts outside the aperture
        DotIm = zeros((maxRad*2)+1,(maxRad*2)+1);
        for dd2=1:NumDots
            DotIm(dotsXY(dd2,1)+maxRad,dotsXY(dd2,2)+maxRad) = 1; %mark all the dot centres
        end
        DotIm = conv2(DotIm,IsolationZone,'same'); %make an image with all the isolation zones overlapping
        DotIm(apMesh>(maxRad))=1; %finally, remove the parts outside the aperture (NB do this after convolution to avoid edge effects)
    end
end

%old dot-by-dot process
%                     badXY = 1; replotcnt = 0;
%                     while badXY
%                         tempXY = [0 0]; tempover = []; tempoverdbl = []; %clear entries
%                         tempRad = rand(1,1).*(maxRad); %generate new position within accepted zone - just use polar generation here for speed
%                         tempAng = rand(1,1).*359;
%                         [tempXY(2),tempXY(1)] = pol2cart(DegToRad(tempAng),tempRad);
%                         %now work out if that fixed the overlap
%                         dotpairDist = dotsXY(dd,:)-tempXY;
%                         [~,dotpairDistRad] = cart2pol(dotpairDist(:,1),dotpairDist(:,2));
%                         if dotpairDistRad<isolationRad
%                             badXY=1;
%                         else
%                             badXY=0; %exit this loop
%                         end
%                         replotcnt=replotcnt+1;
%                         if replotcnt==maxreps
%                             exits = exits+1;
%                             badXY = 0;
%                             movefail = 1;
%                         end
%                     end
%                     if movefail==0
%                         movecnt = movecnt+1;
%                     end
%                 end
%                 dotsXY(dotID(oo),:) = tempXY; %replot selected dot
%                 dotsmoved(movecnt) = dotID(oo); %report back which dots were moved
%             end
%         end
%     end

newdotsXY = round(dotsXY);

end

