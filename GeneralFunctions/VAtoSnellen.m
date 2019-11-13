function Snellen=VAtoSnellen(VA)
%VAtoSnellen - J Greenwood 2010
%gives Snellen values as [6 6] for 6/6 or [6 9] for 6/9
%input visual angle in degrees - will convert to minutes
%based on Holladay (1997) J Refractive Surgery 13: 388-391
%e.g. Snellen = VAtoSnellen(0.0333333)

VA=VA*60; %convert from degrees to minutes of arc
SnellNumer = 6; %for metres, could be 20 for feet
SnellDenom = VA*SnellNumer; %denominator of Snellen fraction
Snellen = [SnellNumer SnellDenom]; %two numbers to give Snellen acuity e.g. 6/6 = [6 6]
