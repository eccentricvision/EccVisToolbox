function [AIC,AICc] = ComputeAIC(LSE,numDataPts,numParams)
% function [AIC] = ComputeAIC(LSE,numDataPts,numParams)
% function to compute the Akaike Information Criterion as a form of model comparison
% uses the form n log(LSE) + 2k, where n = num observations, k = num parameters, LSE = least square error
% lower numbers indicate a better fit, adjusted for the number of parameters
% also computes the corrected AIC of the form AICc = AIC + (2k(k+1) / (n-k-1)
% which has a harsher penalty for high parameters and low observations (recommended by Burnham & Anderson, 2002)
%
% J Greenwood 2015

AIC = numDataPts.*(log(LSE)) + (2*numParams); %uses the form n log(LSE) + 2k, where n = num observations, k = num parameters, LSE = least square error

AICc = AIC + (((2*numParams).*(numParams+1))./(numDataPts - numParams - 1)); %corrected AIC of the form AICc = AIC + (2k(k+1) / (n-k-1)