function rectIm=DrawRect(px,py,x,y,xoff,yoff)
%rectIm=DrawRect(px,py,x,y,xoff,yoff)
%function to draw a rectangle centred within a patch
%x,y = x/y dimensions of rectange, px/py = patch dimensions
%e.g. rectIm = DrawRect(100,240,50,120); imshow(rectIm)
%e.g.2 rectIm = DrawRect(100,240,50,120,10,30); imshow(rectIm)
%
%John Greenwood, v1.1 May 2021 - fixed meshx size issue, added xoff/yoff, shuffled parameter order

if nargin<5
    xoff = 0;
    yoff = 0;
end

halfx  = (x/2);
halfy  = (y/2);
%halfpx = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired
%halfpy = round(py/2)-0.5;

[meshpx,meshpy] = meshgrid(-px/2:px/2-1,-py/2:py/2-1); %coordinates for rectangle
meshpx  = meshpx-xoff;
meshpy  = meshpy-yoff;

rectIm = meshpx.*0; %create blank array
rectIm(abs(meshpx)<halfx & abs(meshpy)<halfy)=1; %draw 1s within rectangle boundaries
