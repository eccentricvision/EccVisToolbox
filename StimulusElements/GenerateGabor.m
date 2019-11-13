function gabor = GenerateGabor(m, n, sigma1,sigma2, theta, theta2,lambda,phase,xoff,yoff,con)
% Generate Gabor: gabor = GenerateGabor(m, n, sigma1,sigma2, theta, theta2,lambda,phase,xoff,yoff,con)
% generates a gabor image with values between -0.5*contrast to +0.5*contrast (just add background contrast as below)
% m/n = x/y patch size; sigma1/sigma2 = Gaussian SD values in 2 dimensions
% theta2 = orientation of grating; theta= orientation of Gaussian patch (if aspect ratio appropriate
% lambda = spatial period in pixels; phase=phase!; xoff/yoff= offset of Gaussian midpoint within patch; con=contrast
% e.g. gabor = GenerateGabor(128,128,16,16,pi/2,pi/2,16,pi/2,0,0,1); gabor=gabor+0.5; imshow(gabor)
%
% John Greenwood 2009

[X,Y] = meshgrid(-m/2:m/2-1,-n/2:n/2-1);
X     = X-xoff;
Y     = Y-yoff;

% rotate co-ordinates
Xt = X.*(cos(pi-theta)) + Y.*(sin(pi-theta));
Yt = Y.*(cos(pi-theta)) - X.*(sin(pi-theta));
Xt2 = X.*(cos(pi/2-theta2)) + Y.*(sin(pi/2-theta2));

MakeGrating = (0.5*con)*cos(Xt2.*((2.0*pi)/lambda)+phase); %use 0.5*contrast to set max and min values around zero
MakeGaussian = exp(-(Xt.*Xt)/(2*sigma1*sigma1)-(Yt.*Yt)/(2*sigma2*sigma2)); %generates values between 0-1;
gabor = MakeGrating.*MakeGaussian;
%gabor = cos(Xt2.*((2.0*pi)/lambda)+phase).*exp(-(Xt.*Xt)/(2*sigma1*sigma1)-(Yt.*Yt)/(2*sigma2*sigma2));
