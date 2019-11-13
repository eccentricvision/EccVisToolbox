function prob = DrawCumuGaussian(xvals,u,var,kp,base,fb)
% function prob = DrawCumuGaussian(x,u,var,kp,base,fb)
% function to draw a Cumulative Gaussian curve
% Compute the probability that a draw from a N(u,var) distribution is less than x.
% input xvals (x axis, pref. at fine resolution), u (mean), var (variance),
% kp (keypress error proportion i.e. val to remove from top e.g. 0.01), 
% base (where the curve hits its minimum, e.g. 0.5 for 2afc tasks),
% fb (forwards/backwards ie whether curve is ascending = 1 or descending = -1)
% e.g. x = [0:0.1:20]; prob = DrawCumuGaussian(x,10,2,0.05,0,1); plot(x,prob);
% John Greenwood, v3.0, April 2018

if ~exist('fb','var') %if there's no fb input then set it to automatically ascending
    fb = 1; 
end

[m,n] = size(xvals);
z = fb.*((xvals - u*ones(m,n))/sqrt(abs(var))); %make a linear function with appropriate slope
%prob = 0.5 + kp.*real(erf(z/sqrt(2))/2);
func = 0.5+real(erf(z/sqrt(2))/2); %makes a cumulative Gaussian between 0-1
prob = base+(func*(1-base-kp)); %scale to between baseline - keypress error rate
