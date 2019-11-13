function dogim = GenerateDoG(xsize,ysize,sigma1X,sigma1Y,sigma2X,sigma2Y,negprop,theta,xoff,yoff)% dogim = GenerateDoG(xsize,ysize,sigma1X,sigma1Y,sigma2X,sigma2Y,negprop,theta,xoff,yoff)% generates a 2D difference-of-gaussian with a given patch size, sd, orientation (in radians where -45 is top right) and offset% sigma1 is for the positive gaussian and sigma2 for the negative, negprop is the proportion of the positive peak for the negative (positive always = 1)% input xsize, ysize, sigma1X,sigma1Y,sigma2X,sigma2Y,negprop,theta,xoff,yoff%%J Greenwood May 2017%% eg1: dogim = GenerateDoG(350,350,16,16,32,32,0.5,pi/2,0,0); ishow(dogim)% eg2: dogim = GenerateDoG(350,350,16,12,32,24,0.5,pi/3,0,0); ishow(dogim)[X,Y]=meshgrid(-xsize/2:xsize/2-1,-ysize/2:ysize/2-1);X  = X-xoff;Y  = Y-yoff;% speedy variablesc1=cos(pi-theta);s1=sin(pi-theta);sigX1_squared=2*sigma1X*sigma1X;sigY1_squared=2*sigma1Y*sigma1Y;sigX2_squared=2*sigma2X*sigma2X;sigY2_squared=2*sigma2Y*sigma2Y;% rotate co-ordinatesXt = X.*c1 + Y.*s1;Yt = Y.*c1 - X.*s1;gaussian1 = exp(-(Xt.*Xt)/sigX1_squared-(Yt.*Yt)/sigY1_squared);gaussian2 = exp(-(Xt.*Xt)/sigX2_squared-(Yt.*Yt)/sigY2_squared).*negprop;dogim     = gaussian1-gaussian2;