function counterphase = GenCountPhaseGrating(m,n,theta,lambda,phase1,phase2,con1,con2)
% counterphase = GenCountPhaseGrating(256,256, deg2rad(0), 32,deg2rad(0),deg2rad(180),0.25,0.75); ishow(counterphase)
%m/n = x/y patch size; sigma1/sigma2 = Gaussian SD values in 2 dimensions
%theta2 = orientation of grating; theta= orientation of Gaussian patch (if aspect ratio appropriate
%lambda = spatial period in pixels; phase=phase!; xoff/yoff= offset of Gaussian midpoint within patch; con=contrast

[X,Y] = meshgrid(-m/2:m/2-1,-n/2:n/2-1);

% rotate co-ordinates
Xt = X.*(cos(pi/2-theta)) + Y.*(sin(pi/2-theta));

MakeGrating1 = (0.5*con1)*cos(Xt.*((2.0*pi)/lambda)+phase1); %use 0.5*contrast to set max and min values around zero
MakeGrating2 = (0.5*con2)*cos(Xt.*((2.0*pi)/lambda)+phase2); %use 0.5*contrast to set max and min values around zero
counterphase = MakeGrating1+MakeGrating2;
%gabor = cos(Xt2.*((2.0*pi)/lambda)+phase).*exp(-(Xt.*Xt)/(2*sigma1*sigma1)-(Yt.*Yt)/(2*sigma2*sigma2));