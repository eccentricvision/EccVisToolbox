function [comp,numscreens,username] = WhereAmI
%function to find the computer name, number of screens and username
%see also LoadGammaCal where this information can be used
%
%J Greenwood July 2015, last modified April 2016

AssertOpenGL; %setup openGL to run the psychtoolbox code

[comp]     = Screen('Computer'); %get the computer details

screens    = Screen('Screens',1); %the handle for each monitor present (the 1 flag is for 'physicalDisplays' - only takes real monitors)
numscreens = numel(screens); %get the number of screens
if IsOSX
    [~, username] = system('whoami');
end

Screen('CloseAll');
