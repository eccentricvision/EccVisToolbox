function [newdotsYX,dotsmoved,exits] = dotOverlapAnnul(dotsYX,isolation,minRad,maxRad)
%function to check for overlapping dot positions, with re-plotting in a circular or annular aperture
%need to input YXmatrix, isolation zone size, and dimensions of aperture
%eg. [dotsYX] = dot1stFrmAnnul(600,200,600); [dotsYX2,dotsmoved,exits]=dotOverlapAnnul(dotsYX,40,200,600); plot(dotsYX(:,2),dotsYX(:,1),'ro',dotsYX2(:,2),dotsYX2(:,1),'go');

% J Greenwood 2009

NumDots = length(dotsYX); %number of dots
halfisolate = round(isolation*0.5);
exits=0;
maxreps = 200; %max no of replots to avoid crashes
for dd = 1:NumDots
    overlaps = find(dotsYX(:,1)<(dotsYX(dd,1)+halfisolate) & dotsYX(:,1)>(dotsYX(dd,1)-halfisolate)); %find any dots overlapping in Yposition
    dbloverlaps = find(dotsYX(overlaps,2)<(dotsYX(dd,2)+halfisolate) & dotsYX(overlaps,2)>(dotsYX(dd,2)-halfisolate)); %dots overlapping in Xpos als

    for oo=1:length(dbloverlaps)
        dotID(oo) = (overlaps(dbloverlaps(oo)));
        if overlaps(dbloverlaps(oo))==dd
            %don't replot identity dot
        else
            badYX = 1; replotcnt = 0;
            while badYX
               tempYX = [0 0]; tempover = []; tempoverdbl = []; %clear entries
               tempRad = (rand(1,1).*(maxRad-minRad))+minRad; %generate new position within accepted zone
               tempAng = (rand(1,1).*359);
               [tempYX(2),tempYX(1)] = pol2cart(DegToRad(tempAng),tempRad);
                tempover = find(dotsYX(:,1)<(tempYX(1)+halfisolate) & dotsYX(:,1)>(tempYX(1)-halfisolate)); %find any dots overlapping in Yposition
                tempoverdbl = find(dotsYX(tempover,2)<(tempYX(2)+halfisolate) & dotsYX(tempover,2)>(tempYX(2)-halfisolate)); %dots overlapping in Xpos also
                if tempoverdbl
                    badYX = 1;
                else
                    badYX = 0; %exit loop
                    break
                end
                replotcnt=replotcnt+1;
                if replotcnt==maxreps
                    exits = exits+1;
                    break
                end
            end
            dotsYX(dotID(oo),:) = tempYX; %replot selected dot
            dotsmoved(dd) = dotID(oo); %check of which dots moved
        end
    end
end
newdotsYX = round(dotsYX);

end

