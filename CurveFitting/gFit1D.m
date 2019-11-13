function [z] = gFit1D(p,data,x)
% 1D gaussian function to estimate initial parameters
% used by FitGauss2D
% input X/Y data and parameters mu and sigma, and get error back
%cx = p(1); wx = p(2); amp = p(3);

zx = exp(-0.5*(x-p(1)).^2./(p(2)^2));
zx = zx/max(All(zx)); %normalise 0-1
z = sum(All((data-zx).^2));

end