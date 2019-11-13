function prob = DrawGaussian(x,uEst,varEst,scaleEst,offsetEst)
% function prob = DrawGaussian(x,uEst,varEst,scaleEst,offsetEst)
% Draws a Gaussian function with four parameters: uEst (mean), varEst
% (variance), scaleEst (height of peak), offsetEst (height of base)
% NB. to work out SD from full width of Gaussian = FW/(2*sqrt(2*log(2))) 
%
% eg. x=[-45:0.1:45]; prob = DrawGaussian(x,0,3,0.8,0.1); plot(x,prob); ylim([0 1]);
% 
% J Greenwood 2009

prob=(scaleEst.*(exp(-(x-uEst).^2 / (2*(varEst.^2)))))+offsetEst; %Gaussian function

