%Calibration test screen
%print a mosaic of tiles for calibration

csize = 200; %size of each square check
numcheck = 5; 

%black and white checks
imCal(1:csize,1:csize,:) = zeros(csize,csize,3);
imCal(1:csize,csize+1:2*csize,:) = ones(csize,csize,3);

%now the colour parts
%red
imCal(1:csize,(csize*2)+1:csize*3,1) = ones(csize,csize);
imCal(1:csize,(csize*2)+1:csize*3,2:3) = zeros(csize,csize,2);

%green
imCal(1:csize,(csize*3)+1:csize*4,1) = zeros(csize,csize,1);
imCal(1:csize,(csize*3)+1:csize*4,2) = ones(csize,csize,1);
imCal(1:csize,(csize*3)+1:csize*4,3) = zeros(csize,csize,1);

%blue
imCal(1:csize,(csize*4)+1:csize*5,1:2) = zeros(csize,csize,2);
imCal(1:csize,(csize*4)+1:csize*5,3)   = ones(csize,csize,1);

imshow(imCal)