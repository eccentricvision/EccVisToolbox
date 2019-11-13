function prob = DrawWeibull(x,p)
% function prob = DrawWeibull(x,p)
% Compute Weibull probability function p = 1-e((-x/p1)^p2)
% three-parameter fit - p(1) and p(2) determine curve shape
% p(1) is lambda - determines the midpoint
% p(2) is the exponent k
% p(3) is 1 or -1 and determines direction of fit
% e.g. x = [0:0.01:20]; prob = DrawWeibull(x,[3 3 1]); plot(x,prob);
% modified J Greenwood 2011

%prob = 0.5 - p(3).*(0.5 * exp(-(x./p(1)).^p(2)));
prob = 1 - p(3).*(exp(-(x./p(1)).^p(2)));
