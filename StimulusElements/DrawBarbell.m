function barIm=DrawBarbell(px,py,length,width,ballrad,ori,con)
%function to draw a barbell centred within a patch - a line and two circles
%px/py = patch dimensions,length/width of line,ballrad=radius of balls,ori=orient (deg),contrast (0-1)
%e.g. barIm=DrawBarbell(200,60,80,3,6,0,0.75); imshow(barIm)
%J Greenwood 2011

%draw line
halfx  = round(length/2);
halfy  = round(width/2);
halfpx = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy = round(py/2)-0.5;
[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
barIm = meshpx.*0; %create blank array
barIm(abs(meshpx)<halfx & abs(meshpy)<halfy)=1; %draw 1s within rectangle boundaries
barends = [-halfx halfx];%[find(sum(barIm,1),1,'first') find(sum(barIm,2),1,'first')];

%draw circles on bar ends
%[meshpx,meshpy] = meshgrid(-ballrad-0.5:ballrad+0.5,-ballrad-0.5:ballrad+0.5); %coordinates for rectangle
for bb=1:2
    meshpc = meshpx-barends(bb);
    [th,r]=cart2pol(meshpc,meshpy); %convert to polar coordinates
    barIm(r<ballrad)=1; %draw 1s within circle boundaries
end
%rotate if needed
if ori>0
    barIm = imrotate(barIm,ori,'crop'); %rotate if required
end
%add contrast
barIm = barIm.*con;