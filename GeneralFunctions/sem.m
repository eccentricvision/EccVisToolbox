function semVal = sem(data,dim)
%semVal = sem(data,dim)
%
%function to calculate standard error of the mean
%standard deviation divided by square root of n
%input data and dimension desired to calculate SEM
%J Greenwood June 2016

semVal=std(data,0,dim)/sqrt(size(data,dim));
