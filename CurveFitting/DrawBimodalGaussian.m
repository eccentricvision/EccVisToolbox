function bigauss = DrawBimodalGaussian(x,u1Est,u2Est,varEst,scale1Est,scale2Est,offsetEst)
% function bigauss = DrawBimodalGaussian(x,u1Est,u2Est,varEst,scale1Est,scale2Est,offsetEst)
%
% Draws a bimodal gaussian function with 6 parameters: u1Est and u2Est (means for gaussians), 
% varEst (variance for both), scale1Est and scale2Est (height of peaks), offsetEst (height of base)
% NB. to work out SD from full width of Gaussian = FW/(2*sqrt(2*log(2))) 
%
% eg. x=[-45:0.1:45]; prob = DrawBimodalGaussian(x,-15,15,3,0.8,0.4,0.1); plot(x,prob); ylim([0 1]);
% 
% J Greenwood 2015

gauss1 = (scale1Est.*(exp(-(x-u1Est).^2 / (2*(varEst.^2)))));
gauss2 = (scale2Est.*(exp(-(x-u2Est).^2 / (2*(varEst.^2)))));

bigauss=gauss1+gauss2+offsetEst; %Gaussian function

