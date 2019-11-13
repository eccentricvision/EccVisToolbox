function prob = DrawPowerFunc(xval,alphaEst,gammaEst,baseEst)
% function prob = DrawPowerFunc(xval,alphaEst,gammaEst,baseEst)
% Draw a power function of the form prob = alpha.*(x.^gamma) + base;
% eg. xval=[0:0.1:60]; prob = DrawPowerFunc(xval,0.0001,3,0.5); plot(x,prob);
% to work out sd from full width = FW/(2*sqrt(2*log(2))) 

prob=alphaEst.*(xval.^gammaEst) + baseEst; %Power function
