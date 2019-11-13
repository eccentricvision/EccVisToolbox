function [comboFit,fit1,fit2,params] = DrawFitMirrorGaussDeriv(xval,yval,avparams)
%[comboFit,fit1,fit2] = DrawFitMirrorGaussDeriv(xval,yval,0)
%Fit the first derivative of a Gaussian independently to each half of the data
%input xval and yval to fit, then avparams = 0 means stitch two curves together, or else avparams = 1 means fit averaged parameters

serlength    = numel(xval); %length of series to be mirrored and fit
serhalf1     = ceil(serlength/2); %two estimates of series length - same if even, differ if odd
serhalf2     = floor(serlength/2);
yvalmir(1,:) = [yval(1:serhalf1)  -fliplr(yval(1:serhalf2))];
yvalmir(2,:) = [-fliplr(yval(serhalf1:end)) yval(serhalf1+1:end)];

xfine = min(xval):0.1:max(xval);
for yy=1:2 %for each mirrored version
    [uEst(yy) varEst(yy) scaleEst(yy)] = FitGaussFirstDeriv(xval,yvalmir(yy,:),[0 1 1],0); %fit first derivative of a gaussian to data - contrain to zero
    [xf fit(yy,:)] = DoGaussFirstDeriv([uEst(yy) varEst(yy) scaleEst(yy)],xfine); %draw fitted function
end
fit1=fit(1,:); fit2=fit(2,:);

if avparams%fit mean of parameters
    uFin = mean(uEst); varFin = mean(varEst); scaleFin = mean(scaleEst);
    [xf,comboFit] = DoGaussFirstDeriv([uFin varFin scaleFin],xfine); %draw fitted function
else%align each half of the two fitted curves
    fitlength = numel(xfine);
    fithalf   = ceil(fitlength/2);
    comboFit  = [fit(1,1:fithalf) fit(2,fithalf+1:end)]; %combine two halves of data
end

params = [uEst; varEst; scaleEst]; 