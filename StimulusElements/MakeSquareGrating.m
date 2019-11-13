function gratingIm = MakeSquareGrating(m,n,theta,lambda,phase,numharmonics,con)
% grating = MakeSquareGrating(m,n,theta,lambda,phase,con);
% m/n = x/y patch size; %theta = orientation of grating; lambda = spatial period in pixels (of fundamental sinewave);
% numharmonics = number of harmonic frequencies to be used; phase=phase!; con=contrast
% e.g. gratingIm = MakeSquareGrating(256,256, pi/2, 24, pi/2,9,1); ishow(gratingIm);
% J Greenwood 2013

harmonics = 1:2:(1+(2*numharmonics));

[X,Y] = meshgrid(-m/2:m/2-1,-n/2:n/2-1);
% rotate co-ordinates
for hh=1:length(harmonics);
      Xt2 = X.*(cos(pi/2-theta)) + Y.*(sin(pi/2-theta));
      grating(:,:,hh) = (1./harmonics(hh))*sin(Xt2.*((2*harmonics(hh)*pi)/lambda)+(phase.*harmonics(hh))); %use 0.5*contrast to set max and min values around zero
%     Xt2 = (X.*harmonics(hh)).*(cos(pi/2-theta)) + (Y.*harmonics(hh)).*(sin(pi/2-theta));
%     grating(:,:,hh) = (1*cos(Xt2.*((2*pi)/lambda)+phase))./harmonics(hh); %use 0.5*contrast to set max and min values around zero
end
gratingIm = (sum(grating,3))./(max(All(sum(grating,3)))).*(0.5*con);
