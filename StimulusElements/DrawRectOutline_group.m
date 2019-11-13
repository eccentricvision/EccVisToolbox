function rectIm=DrawRectOutline_group(PatchX,PatchY,rdiamX,rdiamY,LineWid,angRange,offset)
%DrawRectOutline(PatchX,PatchY,rdiamX,rdiamY,LineWid,angRange,offset)
%function to draw a rectangle outline centred within a patch, with a desired offset and angular range
%(PatchX,PatchY = patch dimensions,rdiamX,rdiamY, = total diameter, LineWid = outline width,
% angRange = angle range to show in deg,offset = [x,y] offset from centre)
%fscale = scaling factor of local flanker with regards to target SOS:
%SPECIFIC TO LANDOLT GROUP EXPT
%e.g.  rectIm = DrawRectOutline_group(300,300,100,100,10,[0 360],[0 0]); imshow(rectIm)
%e.g2. rectIm = DrawRectOutline_group(100,240,60,180,20,[90 270],[-15 0]);
%rectIm = DrawRectOutline_group(540,540,360,360,40, [0 360], [0 0]);imshow(rectIm)
%edited by Alexandra Kalpadakis Smith for grouping experiment

% rdiamX = rdiamX/1.8;
% rdiamY = rdiamY/1.8;

halfpx    = round(PatchX/2)-0.5; %patch, -0.5 to keep number of pixels the same as desired
halfpy    = round(PatchY/2)-0.5;
halfxOut  = round(rdiamX/2);   %outer edge
halfyOut  = round(rdiamY/2);
halfxIn   = round((rdiamX)/2)-LineWid;
halfyIn   = round((rdiamY)/2)-LineWid;

[meshpx,meshpy] = meshgrid(-halfpx+offset(1):halfpx+offset(1),-halfpy+offset(2):halfpy+offset(2)); %coordinates for rectangle within the whole patch

rectIm = meshpx.*0; %create blank array
rectIm(abs(meshpx)<halfxOut & abs(meshpy)<halfyOut)=1; %draw 1s within rectangle edhge boundaries
rectIm(abs(meshpx)<halfxIn & abs(meshpy)<halfyIn)=0; %draw 0s for inner rectangle

%now restrict the range
minAng=deg2rad(min(angRange)); %angles to plot
maxAng=deg2rad(max(angRange));
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates
th(th<0)=th(th<0)+(2*pi);%th(th<180)=wrapTo2pi(th); %wrap to 0-360
rectIm((th<minAng | th>maxAng))=0; %draw 0s outside desired rectangle angular boundaries