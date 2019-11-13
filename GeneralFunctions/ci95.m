function ciVal = ci95(data,dim)
%ciVal = ci95(data,dim)
%
%function to calculate 95% confidence interval for the mean
%computed as SEM (standard deviation divided by square root of n) * 1.96
%input data and dimension desired to calculate CI
%NB this is the CI for the mean of the distribution not the range of data - for that use range95
%
%J Greenwood June 2016

ciVal=(std(data,0,dim)/sqrt(size(data,dim))).*1.96; 
