function prob = DrawBiGaussian(x,uEst,varEst1,varEst2,scaleEst1,scaleEst2,offsetEst,thetaEst)
% function prob = NormalCumulative(x,u,var,offset,theta)
% eg. x=-45:45; prob=DrawBiGaussian(x,0,10,5,0.5,1,0.5,45); plot(x,prob);
% Computes two Gaussian probability distributions at a given angular separation with a linear sum
% uEst is the centre of mass for the two summed distributions
% thetaEst sets the separation between the two means on the same scale

% Compute the probability that a draw from a N(u,var)
% distribution is less than x.

u1    = uEst-round(0.5*thetaEst); %
u2    = uEst+round(0.5*thetaEst);
prob1 = (scaleEst1.*(exp(-(x-u1).^2 / (2*(varEst1.^2))))); %Gaussian function  prob1=scaleEst1.*NormalPDF(x,u1,varEst1^2);
prob2 = (scaleEst2.*(exp(-(x-u2).^2 / (2*(varEst2.^2))))); %Gaussian function  prob2=scaleEst2.*NormalPDF(x,u2,varEst2^2);
prob  = (prob1+prob2)+offsetEst; 
