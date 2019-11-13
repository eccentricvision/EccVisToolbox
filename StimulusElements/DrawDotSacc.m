function dotIm=DrawDotSacc(px,py,dotrad,indotrad,dotcon,indotcon,bgcon)
% dotIm=DrawDotSacc(px,py,dotrad,indotrad,dotcon,indotcon,bgcon)
% function to draw a double dot similar to the centre of the clocks used in the Crowded Saccades task
% px/py = patch dimensions, dotrad=central dot radius,indotrad = inner central dot radius, dotcon,indotcon,bgcon = contrast of each element (0-1)
% e.g. dotIm = DrawDotSacc(100,100,30,15,0,1,0.5); imshow(dotIm)
% J Greenwood 2011

halfpx = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired (and centre stimulus in middle with even pixels)
halfpy = round(py/2)-0.5;

[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates

dotIm = (meshpx.*0)+bgcon; %create blank array with background colour
dotIm(r<dotrad)=dotcon; %draw central dot
dotIm(r<indotrad)=indotcon;

