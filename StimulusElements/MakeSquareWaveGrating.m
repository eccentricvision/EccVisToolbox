function gratingIm = MakeSquareWaveGrating(m,n,theta,lambda,phase,numharmonics,con)
% grating = MakeSquareWaveGrating(m,n,theta,lambda,phase,numharmonics,con)
% m/n = x/y patch size; %theta = orientation of grating; lambda = spatial period in pixels (of fundamental sinewave);
% numharmonics = number of harmonic frequencies to be used; phase=phase!; con=contrast (0-1)
% generates final image with range between -1 and 1 or whatever con is
% NB sums sine waves, thus final output is in sine phase (whereas the Generate Grating code using cosine phase)
% e.g. gratingIm = MakeSquareWaveGrating(256,256, pi/2, 24, pi/2,9,1); ishow(gratingIm);
% J Greenwood 2013

harmonics = 1:2:(1+(2*numharmonics));

[X,Y] = meshgrid(-m/2:m/2-1,-n/2:n/2-1);
% rotate co-ordinates
for hh=1:length(harmonics);
      Xt2 = X.*(cos(pi/2-theta)) + Y.*(sin(pi/2-theta));
      grating(:,:,hh) = (1./harmonics(hh))*sin(Xt2.*((2*harmonics(hh)*pi)/lambda)+(phase.*(harmonics(hh))));%(1./harmonics(hh))*sin(Xt2.*((2*harmonics(hh)*pi)/lambda)+(phase.*harmonics(hh))); %use 0.5*contrast to set max and min values around zero
%     Xt2 = (X.*harmonics(hh)).*(cos(pi/2-theta)) + (Y.*harmonics(hh)).*(sin(pi/2-theta));
%     grating(:,:,hh) = (1*cos(Xt2.*((2*pi)/lambda)+phase))./harmonics(hh); %use 0.5*contrast to set max and min values around zero
end
gratingIm = round((sum(grating,3))./(max(All(sum(grating,3))))); %sum harmonics
gratingIm(gratingIm>1)=1;
gratingIm(gratingIm<-1)=-1; %clip to appropriate range
gratingIm = gratingIm.*(con); %adjust by contrast
