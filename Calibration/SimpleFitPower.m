% SimpleFitPower
% Fits voltage versus luminance data and makes nice
% inline functions for converting between them
% returned as a structure called LR
%
% Steven Dakin (s.dakin@ucl.ac.uk) 06/06
% modified J Greenwood April 2016
%
function LR=SimpleFitPower(V,L)

% Normalise voltages and luminances to (0.0-1.0)
LR.LMin=min(L); 
LR.LMax=max(L);    
L1=(L-LR.LMin)./(LR.LMax-LR.LMin);
LR.VMin=min(V); 
LR.VMax=max(V);
V1=V./LR.VMax;

% Fit data
opt = optimset(optimset,'MaxFunEvals',10000);
[LR.VtoLpow,err1] = fminsearch(@pFitFun,[1],opt,V1,L1);
[LR.LtoVpow,err1] = fminsearch(@pFitFun,[1],opt,L1,V1);

% Make inline objects
LR.VtoLfun=inline('LR.LMin+((LR.LMax-LR.LMin).*((V./LR.VMax).^LR.VtoLpow))','LR','V');
LR.LtoVfun=inline('LR.VMax.*((L-LR.LMin)./(LR.LMax-LR.LMin)).^LR.LtoVpow','LR','L');
LR.VtoRGBfun=inline('reshape([uint8(V./256) uint8(mod(V,256)) zeros(size(V,1),size(V,2),''uint8'')],[size(V,1) size(V,2) 3])','LR','V');

% Make dense list of voltages and luminances for the plots
FullV=linspace(V(1),V(end),1000);
FullL=linspace(L(1),L(end),1000);

% Plot original data and fits
subplot(1,2,1); 
plot(V,L,'o',FullV,LR.VtoLfun(LR,FullV),'r-'); 
xlabel('Monitor voltage');
ylabel('Luminance output (cd/m2)');
axis square;
drawnow;

subplot(1,2,2); 
plot(L,V,'o',FullL,LR.LtoVfun(LR,FullL),'r-'); 
xlabel('Luminance output (cd/m2)');
ylabel('Monitor voltage');
axis square;
drawnow;

% Return error between power function and data
function err1=pFitFun(p,x,data)
prob=x.^p(1);
err1=sum((prob-data).^2);