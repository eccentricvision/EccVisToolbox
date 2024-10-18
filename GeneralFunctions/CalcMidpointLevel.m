function [mpLevel,chanceLevel] = CalcMidpointLevel(NumAlt,verbose)
%[mpLevel,chanceLevel] = CalcMidpointLevel(NumOpt)
%
%calculates the midpoint level (mpLevel) and chance level (chancelevel) in
%an xAFC paradigm, with x = the number of alternatives/options (NumAlt) as input
%returns values in proportion correct (0-1)
%verbose flag (0=no / 1=yes) prints outcomes to screen, otherwise just
%returns the values to the workspace
%
%e.g. [mpLevel,chanceLevel] = CalcMidpointLevel(12,1);
%J Greenwood April 2024

chanceLevel = 1./NumAlt; %proportion correct at chance
mpLevel     = chanceLevel+((1-chanceLevel)./2); %midpoint is midway from chance to ceiling

if verbose %print outcome to command window
    disp(' ');
    fprintf('Chance level with %1.0f AFC: %1.4f \n',NumAlt,chanceLevel);
    fprintf('Midpoint level with %1.0f AFC: %1.4f \n',NumAlt,mpLevel);
    disp(' ');
end