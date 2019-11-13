function [ImSize]=VAToPix(viewdist,PixSize,desiredVA)
%VAToPix (formerly VAcalc.m) - J Greenwood 2010
%returns pixel size for a desired visual angle at a given viewing distance
%need to input viewing distance, pixel size (both in cm), and desired VA
%eg. [ImSize]=VAToPix(57,0.035,2)

%ImSize = (viewdist * tand(desiredVA))/PixSize; %multiply viewing distance by tan of desired visual angle then divide by pixsize
ImHalf = (viewdist * tand(desiredVA/2))/PixSize; %multiply viewing distance by tan of desired visual angle (divided in half!) then divide by pixsize
ImSize = ImHalf.*2; %double angle (two right angled triangles)
