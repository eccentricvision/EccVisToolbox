function [stairvalnew,newdrctn,ntrue,nrev,reversal] = LevittStaircase(stairvalold,correct,olddrctn,ntrue,ntruemax,nrev,stepsize,min,max)
%function to operate a staircase using the Levitt method
%need to input current staircase value, correct (0=wrong 1=right) direction (0=not moved, 'down','up'),
%num true thus far, the max number true required, number of reversals to be
%made, stepsize value for staircase and min/max of the run

%returns new staircase value, new staircase direction, num true in a row,
%number of reversals made, and whether trial was a reversal or not (0/1)

%eg. [stairvalnew,newdrctn,ntrue,nrev,reversal] = LevittStaircase(50,1,'up',2,3,0,16,1,50)
%J Greenwood 2009

if correct %response correct
    ntrue = ntrue + 1; %increment true counter
    newdrctn = 'down'; %going down
    if ~olddrctn %staircase yet to move - drops quickly to threshold
        stairvalnew = stairvalold - stepsize;  %drops the staircase value
        reversal = 0; %(not a reversal point)
    else
        if ntrue == ntruemax %decrease staircase
            ntrue = 0; %reset counter
            stairvalnew = stairvalold - stepsize;

            change=strcmp(olddrctn,newdrctn); %determines value of change
            if ~change %going in same direction
                reversal = 0; %not a reversal
            else %is a reversal
                reversal = 1;
                nrev = nrev+1;
            end
        else
            stairvalnew = stairvalold; %no step size taken since ntrue<>ntruemax (eg 3) ie. no stim intensity change
            reversal=0;
        end
    end
else %response incorrect
    ntrue = 0;
    newdrctn = 'up'; %going up
    stairvalnew = stairvalold + stepsize;
    change=strcmp(olddrctn,newdrctn); %determines value of change
    if ~change %same direction
        reversal = 0; %not a reversal
    else %direction has changed
        reversal = 1;
        nrev=nrev+1;
    end
end
if stairvalnew < min %can't go below minimum val of staircase
    stairvalnew = min;
elseif stairvalnew > max %nor above
    stairvalnew = max;
end
