function VA=PixToVA(viewdist,PixSize,NumPixels)
%PixToVA - J Greenwood 2010
%gives visual angle calculations (in degrees) for pixel inputs
%need to input viewing distance, pixel size (both in cm), and height/size of element in pixels (NumPixels)
%e.g. VA = PixToVA(57,0.035,60)
%or e.g. VA = PixToVA(300,0.028,4)

VAhalf = atand(((NumPixels/2)*(PixSize))/viewdist); %use half angle (right angled triangle)
VA = VAhalf.*2; %double to get full angle
