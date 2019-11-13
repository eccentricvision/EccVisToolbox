function prob = DrawDoG(x,uEst,var1Est,var2Est,scale1Est,scale2Est,offsetEst)
% function prob = DrawDoG(x,uEst,var1Est,var2Est,scale1Est,scale2Est,offsetEst)
% Draws a Difference of Gaussian ("Mexican Hat") function with 6
% parameters: uEst (mean), varEst1 and 2 (variance), scaleEst1 and 2 (height of peaks), and offsetEst (height of base)
% First Gaussian is positive, second is negative surround (so var2Est typically bigger than Var1Est)
% NB. to work out SD from full width of Gaussian = FW/(2*sqrt(2*log(2))) 
%
% eg. x=[-45:0.1:45]; prob = DrawDoG(x,0,3,12,0.8,0.2,0.3); plot(x,prob); ylim([0 1]);
% eg. x=[-45:0.1:45]; prob = DrawDoG(x,0,3,12,0.8,0.2,0); plot(x,prob);
% 
% J Greenwood 2015

prob1 = (scale1Est.*(exp(-(x-uEst).^2 / (2*(var1Est.^2))))); %positive Gaussian function
prob2 = (scale2Est.*(exp(-(x-uEst).^2 / (2*(var2Est.^2))))); %negative Gaussian function
prob  = prob1 - prob2 + offsetEst; 