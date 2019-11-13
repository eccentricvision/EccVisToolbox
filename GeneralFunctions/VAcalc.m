function [ImSize]=VAcalc(viewdist,PixSize,desiredVA)
%VAcalc - used many places but identical to VAToPix - J Greenwood 2010
%returns pixel size for a desired visual angle at a given viewing distance
%need to input viewing distance, pixel size (both in cm), and desired VA
%eg. [ImSize]=VAcalc(57,0.035,2)

ImHalf = (viewdist * tand(desiredVA/2))/PixSize; %multiply viewing distance by tan of desired visual angle (divided in half!) then divide by pixsize
ImSize = ImHalf+ImHalf; %add two angles (two right angled triangles)
