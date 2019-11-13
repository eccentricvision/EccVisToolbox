function prob = DrawDoGWrap(x,uEst,var1Est,var2Est,scale1Est,scale2Est,offsetEst)
% function prob = DrawGaussianWrap(x,uEst,varEst,scaleEst,offsetEst)
% Draws a Difference of Gaussian ("Mexican Hat") function with 6
% parameters: uEst (mean), varEst1 and 2 (variance), scaleEst1 and 2 (height of peaks), and offsetEst (height of base)
% First Gaussian is positive, second is negative surround (so var2Est typically bigger than Var1Est)
% NB. to work out SD from full width of Gaussian = FW/(2*sqrt(2*log(2))) 
%
% wraps values from one end of the x range to the other
% adds the full range of values on either side (e.g. with -180 to 180 it
% goes to -720:720 so is tolerant to varEst values up to ~150 (disjunctive
% summing errors with values above that)
%
% eg.  x=[-180:0.1:180]; prob = DrawDoGWrap(x,-160,40,80,0.8,0.4,0.1); plot(x,prob); ylim([0 1]);
% eg2. x=[0:0.1:360]; prob = DrawDoGWrap(x,10,30,45,0.4,0.3,0); plot(x,prob); 
% eg3. x=[0:0.1:360]; prob = DrawDoGWrap(x,10,30,45,0.4,0,0); plot(x,prob); 
% 
% J Greenwood August 2018

x         = round(x,2); %round x to 2 decimal places
fullrange = max(x(:))-min(x(:)); %get range for wrapping
xdiff     = abs(x(1)-x(2)); %get scale of x-axis
xfull     = round(min(x(:))-round(fullrange):xdiff:max(x(:))+round(fullrange),2); %produce full x-axis on same scale plus the same again just to ensure get any wrapped values and round to 2 decimal places

%generate full function over entire range
probfull1 = (scale1Est.*(exp(-(xfull-uEst).^2 / (2*(var1Est.^2))))); %positive Gaussian function
probfull2 = (scale2Est.*(exp(-(xfull-uEst).^2 / (2*(var2Est.^2))))); %negative Gaussian function
probfull  = probfull1 - probfull2 + offsetEst; 

%wrap values
UpValsX    = round(xfull(xfull>=max(x(:)))-fullrange,2);
UpValsProb = probfull(xfull>=max(x(:)));

LoValsX    = round(xfull(xfull<=min(x(:)))+fullrange,2);
LoValsProb = probfull(xfull<=min(x(:)));

probfull(ismember(xfull,UpValsX)) = probfull(ismember(xfull,UpValsX))+UpValsProb;
probfull(ismember(xfull,LoValsX)) = probfull(ismember(xfull,LoValsX))+LoValsProb;

%clip to requested range
xind = (xfull>=min(x(:)) & xfull<=max(x(:)));%ismember(single(xfull),single(x)); %convert to doubles for comparison
prob = probfull(xind)+offsetEst; %add offset values here at the end to avoid summing them above