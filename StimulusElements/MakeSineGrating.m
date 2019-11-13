function gratingIm = MakeSineGrating(m,n,theta,lambda,phase,con)
% grating = MakeSineGrating(m,n,theta,lambda,phase,con);
% m/n = x/y patch size; %theta = orientation of grating; lambda = spatial period in pixels; phase=phase!; con=contrast
% e.g. gratingIm = MakeSineGrating(256,256, pi/2, 16,pi/2,1); ishow(gratingIm);
% J Greenwood 2013

[X,Y] = meshgrid(-m/2:m/2-1,-n/2:n/2-1);
% rotate co-ordinates
Xt2 = X.*(cos(pi/2-theta)) + Y.*(sin(pi/2-theta));
gratingIm = (0.5*con)*cos(Xt2.*((2.0*pi)/lambda)+phase); %use 0.5*contrast to set max and min values around zero
