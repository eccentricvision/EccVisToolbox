function [halfVal,LoVal,UpVal] = range95(data,dim)
%ciVal = range95(data,dim)
%
%function to calculate the range containing 95% of the data
%assumes a normal distribution
%can also be estimated using quantile(data,[.025 .975]); 
%but here computed as standard deviation * 1.96
%input data and dimension desired to calculate 95% range
%halfVal reported as half the range so mean±range95 is the full range (easier for plotting this way)
% also outputs LoVal and UpVal as upper and lower ends of the range if desired
%
%J Greenwood June 2018

halfVal = std(data,0,dim).*1.96; %how far from mean to go to catch 95% of data (in each direction)

LoVal = mean(data,dim)-halfVal; %lower limit of 95% range
UpVal = mean(data,dim)+halfVal; %upper limit of 95% range
