function prob = DrawSkewGaussian(x,uEst,LvarEst,RvarEst,scaleEst,offsetEst)
% function prob = DrawSkewGaussian(x,uEst,LvarEst,RvarEst,scaleEst,offsetEst)
% Draws a skewed Gaussian function with five parameters: uEst (mean), varEst (left
% and right side variance), scaleEst (height of peak), offsetEst (height of base)
% NB. to work out SD from full width of Gaussian = FW/(2*sqrt(2*log(2))) 
%
% eg. x=[-45:0.1:45]; prob = DrawSkewGaussian(x,0,12,3,0.8,0.1); plot(x,prob); ylim([0 1]);
% 
% J Greenwood 2015

probLeft  = (scaleEst.*(exp(-(x-uEst).^2 / (2*(LvarEst.^2)))))+offsetEst; %LHS Gaussian function
probRight = (scaleEst.*(exp(-(x-uEst).^2 / (2*(RvarEst.^2)))))+offsetEst; %RHS Gaussian function

[~,minind]=min(abs(x-uEst)); %find the x-axis location of the mean value

prob = [probLeft(1:minind-1) mean([probLeft(minind) probRight(minind)]) probRight(minind+1:end)]; %stitch together the skewed gaussian



