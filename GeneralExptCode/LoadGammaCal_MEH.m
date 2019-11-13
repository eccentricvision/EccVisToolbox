function [WhereRU,LR,gamCal,gammaMethod,ExpScreen,MainScreen,TwoKBs] = LoadGammaCal(comp,screens)
%function [WhereRU,LR,gamCal,gammaMethod,ExpScreen,MainScreen] = LoadGammaCal(comp,screens)
%function to find out which computer you're on, get the correct gamma
%calibration file for that setup and load it
%
%requires structure 'comp' obtained from a call to [comp] = Screen('Computer')
%returns WhereRU as a number and gamCal as a file location, plus LR as a
%structure with the relevant gamma calibration setup
%
%J Greenwood July 2015, last modified April 2016 (automated username detection for iMac)
%
% e.g. [comp,numscreens] = WhereAmI; [WhereRU,gamCal,LR,gammaMethod] = LoadGammaCal(comp)

numscreens = numel(screens);

if strcmp('mac10',comp.machineName) %John's office
    gamCal       = '/Users/John/Documents/MATLAB/Calibration/MonitorData/CalData.mat'; %select Gamma calibration files
    WhereRU      = 1;
    TwoKBs       = 0; %one keyboard or two?
    gammaMethod  = 0; %0/1/2 = standard LUT/bits++/bitstealing
    ExpScreen    = numscreens; %max(screens)
    MainScreen   = 1; %min(screens)
elseif strcmp('John MacBook',comp.machineName) %John's macbook
    WhereRU      = 2;
    gamCal       = '/Users/John/Documents/MATLAB/Calibration/MonitorData/CalData.mat'; %select Gamma calibration files
    TwoKBs       = 0; %one keyboard or two?
    gammaMethod  = 0; %0/1/2 = standard LUT/bits++/bitstealing
    ExpScreen    = 1; %max(screens)
    MainScreen   = 1; %max(screens)
elseif strcmp('mac13',comp.machineName) %lab iMac (NEC DiamondView monitor)
    WhereRU       = 3;
    [~, username] = system('whoami');
    gamCal        = strcat('/Users/',username,'/Documents/MATLAB/Calibration/MonitorData/CalDataDiamondPlus.mat'); %select Gamma calibration files
    TwoKBs        = 1; %one keyboard or two?
    gammaMethod   = 0; %0/1/2 = standard LUT/bits++/bitstealing
    ExpScreen     = numscreens; %max(screens)
    MainScreen    = 1; %min(screens)
elseif strcmp('greenwood01',comp.machineName) %lab PC
    WhereRU      = 4;
    gamCal       = 'C:\Documents\MATLAB\Calibration\MonitorData\CalDataAsusVG278right3Dmode.mat';
    TwoKBs       = 1; %one keyboard or two?
    gammaMethod  = 0; %0/1/2 = standard LUT/bits++/bitstealing
    ExpScreen    = 2; %max(screens)
    MainScreen   = 3; %min(screens)
elseif strcmp('DakinLab01',comp.machineName) %Moorfields PC
    WhereRU      = 5;
    gamCal       = 'C:\Users\JohnG\MATLAB\Calibration\MonitorData\CalDataVG278_MEH_3Dmode.mat'; %CalDataAsusVG278moorfields3Dmode.mat';
    TwoKBs       = 1; %one keyboard or two?
    gammaMethod  = 0; %0/1/2 = standard LUT/bits++/bitstealing
    ExpScreen    = 1; %max(screens)
    MainScreen   = 1; %min(screens)
elseif strcmp('macXX',comp.machineName) %Alexandra's office iMac
    WhereRU      = 6;
    gamCal       = '/Users/Alex/Documents/MATLAB/Calibration/MonitorData/CalData.mat'; %select Gamma calibration files
    TwoKBs       = 0; %one keyboard or two?
    gammaMethod  = 0; %0/1/2 = standard LUT/bits++/bitstealing
    ExpScreen    = max(screens);
    MainScreen   = min(screens);
else %unknown location
    WhereRU      = 99;
    gamCal       = '___';
    TwoKBs       = 0;
    gammaMethod  = 0; %0/1/2 = standard LUT/bits++/bitstealing
    ExpScreen    = 0;
    MainScreen   = 0;
end

if WhereRU<99 %if there's an appropriate gamma calibration file
    load(gamCal); %load gamma correction functions - gives LR to be returned by the function
else %if the location is unknown then return LR as a 0 and get the details to be entered here
    LR = 0;
end
