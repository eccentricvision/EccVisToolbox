function rectIm=DrawRect(x,y,px,py)
%rectIm=DrawRect(x,y,px,py)
%function to draw a rectangle centred within a patch
%x,y = x/y dimensions of rectange, px/py = patch dimensions
%e.g. rectIm = DrawRect(50,120,100,240); imshow(rectIm)

halfx  = round(x/2);
halfy  = round(y/2);
halfpx = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy = round(py/2)-0.5;

[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
rectIm = meshpx.*0; %create blank array
rectIm(abs(meshpx)<halfx & abs(meshpy)<halfy)=1; %draw 1s within rectangle boundaries
