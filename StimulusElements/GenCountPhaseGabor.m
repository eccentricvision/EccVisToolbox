function counterphase = GenCountPhaseGabor(m, n, sigma1,sigma2, theta, theta2,lambda,phase1,phase2,xoff,yoff,con1,con2)
% counterphase = GenCountPhaseGabor(256,256, 32,32, deg2rad(0), deg2rad(0), 32, deg2rad(0),deg2rad(180),0,0,1,1);
%m/n = x/y patch size; sigma1/sigma2 = Gaussian SD values in 2 dimensions
%theta2 = orientation of grating; theta= orientation of Gaussian patch (if aspect ratio appropriate
%lambda = spatial period in pixels; phase=phase!; xoff/yoff= offset of Gaussian midpoint within patch; con=contrast

[X,Y] = meshgrid(-m/2:m/2-1,-n/2:n/2-1);
X     = X-xoff;
Y     = Y-yoff;

% rotate co-ordinates
Xt = X.*(cos(pi-theta)) + Y.*(sin(pi-theta));
Yt = Y.*(cos(pi-theta)) - X.*(sin(pi-theta));
Xt2 = X.*(cos(pi/2-theta2)) + Y.*(sin(pi/2-theta2));

MakeGrating1 = (0.5*con1)*cos(Xt2.*((2.0*pi)/lambda)+phase1); %use 0.5*contrast to set max and min values around zero
MakeGrating2 = (0.5*con2)*cos(Xt2.*((2.0*pi)/lambda)+phase2); %use 0.5*contrast to set max and min values around zero
MakeGaussian = exp(-(Xt.*Xt)/(2*sigma1*sigma1)-(Yt.*Yt)/(2*sigma2*sigma2)); %generates values between 0-1;
counterphase = (MakeGrating1+MakeGrating2).*MakeGaussian;
%gabor = cos(Xt2.*((2.0*pi)/lambda)+phase).*exp(-(Xt.*Xt)/(2*sigma1*sigma1)-(Yt.*Yt)/(2*sigma2*sigma2));