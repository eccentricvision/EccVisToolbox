function [newdotsYX,dotsmoved,exits] = dotOverlapSquare(dotsYX,isolation,stimsize,xmin,ymin);
%function to check for overlapping dot positions, with re-plotting in a square aperture
%need to input YXmatrix, isolation zone size, and dimensions of aperture
%eg. DotsYX1=round(([rand(24,1) rand(24,1)]*400)-200); DotsYX1(25:27,:)=DotsYX1(1:3,:); [DotsYX2,dotsmoved,exits]=dotOverlapSquare(DotsYX1,4,300,-150,-150);

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
                tempYX = (rand(1,2)*stimsize)+[ymin xmin]; %new YX position
                tempover = []; tempoverdbl = []; %clear entries
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
newdotsYX = dotsYX;

end

