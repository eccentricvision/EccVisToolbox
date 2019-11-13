function rectIm=DrawRectOff(x,y,px,py,offset)
%rectIm=DrawRect(x,y,px,py,offset)
%function to drOffaw a rectangle with an offset within a patch
%x,y = x/y dimensions of rectange, px/py = patch dimensions
%e.g. rectIm = DrawRectOff(50,120,300,240,[50 0]); imshow(rectIm)

halfx  = round(x/2);
halfy  = round(y/2);
halfpx = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy = round(py/2)-0.5;

[meshpx,meshpy] = meshgrid(-halfpx+offset(1):halfpx+offset(1),-halfpy+offset(2):halfpy+offset(2)); %coordinates for rectangle
rectIm = meshpx.*0; %create blank array
rectIm(abs(meshpx)<halfx & abs(meshpy)<halfy)=1; %draw 1s within rectangle boundaries
