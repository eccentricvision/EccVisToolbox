function [sigXEst,sigYEst,oriEst,xoffEst,yoffEst] = Fit2DGauss(inImage,WhichFit,paramVals)
% [uEst,varEst,scaleEst,offsetEst] = FitGaussian(inputs,prop,[WhichFit],[paramVals])
% fits a 2D Gaussian to an image with frequency data in an x/y grid
% fits x parameters: peak, SDx, SDy, orientation, offsetX and offsetY
% e.g.    load('/Users/jgreenwood/MatlabFiles/Curve Fitting/2DGaussTestData2.mat'); [sizey sizex] = size(inImage); [sigXEst,sigYEst,oriEst,xoffEst,yoffEst] = Fit2DGauss(inImage,[1 1 1 1 1],0);
% cont'd: [ellX ellY] = DrawEllipsePerim(xoffEst+(sizex/2),yoffEst+sizey/2,max([sigXEst sigYEst])*1.28,min([sigXEst sigYEst])*1.28,(oriEst),50); ishow(inImage); hold on; plot(ellX,ellY,'r-')
% or:     gaussian = GenerateGaussian(sizex,sizey,sigXEst,sigYEst,deg2rad(oriEst),xoffEst,yoffEst); ishow(gaussian+inImage)

opt = optimset(optimset,'MaxFunEvals',1000,'Display','off','TolFun',10e-4);%,'LargeScale','off');

[sizey sizex] = size(inImage);
angles        = linspace(-180,180,25); %angles of rotation to test (between +/- 180deg where +45 is top right, then invert to -45 as top right later)
for aa=1:length(angles)-1
    fitImage(:,:,aa)              = imrotate(inImage,angles(aa),'crop')./max(All(inImage)); %rotate and normalise image to 0-1
    [cx(aa),cy(aa),sx(aa),sy(aa)] = centerofmass(fitImage(:,:,aa)); %gives an estimate of centre x/y and variation x/y
    xmin       = find(sum(fitImage(:,:,aa),1),1);
    xmax       = find(sum(fitImage(:,:,aa),1),1,'last' );
    xrange(aa) = xmax-xmin;
    ymin       = find(sum(fitImage(:,:,aa),2),1);
    ymax       = find(sum(fitImage(:,:,aa),2),1,'last' );
    yrange(aa) = ymax-ymin;
    errRan(aa) = sum(abs([yrange(aa)-xrange(aa)]));%want to maximise the anisotropy to find the right orientation if there's an ellipse there
end
rotMax    = max(errRan);
ori       = -deg2rad(angles(find(errRan==rotMax))); %guess for rotation of the image in radians
[oo,oind] = min(abs(ori)); %find the closest value to zero (if multiple are present)
oriGuess  = ori(oind); %take a single value to avoid multiples

[cx,cy,sx,sy] = centerofmass(inImage); %gives an estimate of centre x/y and variation x/y
cx=cx-0.5*sizex;%express as plus/minus centre
cy=cy-0.5*sizey;

Xdata = (sum(fitImage(:,:,oind),1)./max(sum(fitImage(:,:,oind),1))); %take normalised X-axis values for most anisotropic image orientation
Ydata = (sum(fitImage(:,:,oind),2)./max(sum(fitImage(:,:,oind),2)))'; %take normalised Y-axis values for most anisotropic image orientation

[ux,sx,scalex,offx] = FitGaussian((1:numel(Xdata))-0.5*sizex,Xdata,[1 1 1 0],0); %fit gaussian to xdata
[uy,sy,scaley,offy] = FitGaussian(-(1:numel(Ydata))-0.5*sizey,Ydata,[1 1 1 0],0); %fit gaussian to ydata ,note inverted y-axis
 
%  xGauss = DrawGaussian((1:numel(Xdata))-0.5*sizex,ux,sx,scalex,offx);
%  yGauss = DrawGaussian(-(1:numel(Ydata))-0.5*sizey,uy,sy,scaley,offy);
%  
%  plot(1:numel(Xdata),Xdata,'ro',1:numel(Xdata),xGauss,'r-'); 
%  hold on
%  plot(1:numel(Ydata),Ydata,'bo',1:numel(Ydata),yGauss,'b-');



%sx = xrange(oind)./6; %range divided by 6 SDs
%sy = yrange(oind)./6;

%get guess of mean and SD for x-axis
% mx   = inImage(round(cy),:);
% x1D  = 1:sizex;
% ip1D = [cx,sx];
% fp1D = fminunc(@gfit1D,ip1D,opt,mx,x1D);
% cx   = fp1D(1);
% sx   = fp1D(2);
% %get guess of mean and SD for y-axis
% my   = inImage(:,round(cx))';
% y1D  = 1:sizey;
% ip1D = [cy,sy];
% fp1D = fminunc(@gfit1D,ip1D,opt,my,y1D);
% cy   = fp1D(1);
% sy   = fp1D(2);

%xo        = xmin+(0.5*xrange);
%yo        = ymin+(0.5*yrange);
%yoffGuess = yo-(imsize(1)/2);  %express as plus/minus centre
%xoffGuess = xo-(imsize(2)/2);

%make a Gaussian blurred version of the input image for the fitting
%set SD of blur to be size/12;
% blurlevels = [0 mean([xrange yrange])./48 mean([xrange yrange])./24]; %use two blur levels
% for bb=1:3
%     if bb==1 %no blur on first image
%         fitIm(:,:,bb) = inImage;
%     else
bb=1; blurlevels = 2;%mean([xrange(1) yrange(1)])./6;
sigmaX=blurlevels(bb);%xrange./24;%(1/12)*(imsize(1)); %pixel SDs of Gaussian filter
sigmaY=blurlevels(bb);%yrange./24;%(1/12)*(imsize(2)); %pixel SDs of Gaussian filter
m=sigmaX*2.5; n=sigmaY*2.5; %radii of filter patch (around zero, always odd numbers)
[X,Y] = meshgrid(-m:m,-n:n);
Xt = X.*(cos(pi)) + Y.*(sin(pi));
Yt = Y.*(cos(pi)) - X.*(sin(pi));
filt = exp(-(Xt.*Xt)/(2*sigmaY*sigmaY)-(Yt.*Yt)/(2*sigmaX*sigmaX)); %generates Gaussian filter with values between 0-1;

inImage = conv2(inImage,filt,'same'); %convolve input image and filter
inImage = inImage./max(max(inImage)); %normalise 0-1
%         fitIm(:,:,bb) = conv2(inImage,filt,'same'); %convolve input image and filter
%         fitIm(:,:,bb) = fitIm(:,:,bb)./max(max(fitIm(:,:,bb))); %normalise 0-1
%     end
% end

defVals=[sx sy oriGuess cx cy]; % Default parameters for fit
fixVals=defVals; % Parameters that will be filled in in the absence of user-provided values

if ~exist('WhichFit') % If the user didn'y specify which parmeters to fit...
    WhichFit=[1 1 1 1 1]; % ... assume they want to fit everything
end

guess1=defVals(find(WhichFit)); % Initial guess for the parmeters to be fit
if exist('paramVals')
    fixVals(find(~WhichFit))=paramVals; % If user gave us some fixed params slot them into fixVals
end

[pOut,err1] = fminsearch(@gFitFun,guess1,opt,inImage,WhichFit,fixVals,[sizex sizey]); % Does the fit

% Make a list of the all the fit and fixed params
estParams=[0 0 0 0 0];
estParams(find(WhichFit))=pOut;
estParams(find(~WhichFit))=fixVals(find(~WhichFit));

sigXEst = (abs(estParams(1)));
sigYEst = (abs(estParams(2)));
oriEst  = rad2deg(estParams(3)); %don't take absolute of orientation (can be -ve)
xoffEst = abs(estParams(4));
yoffEst = abs(estParams(5));


%%
    function err1=gFitFun(InParams,data,WhichFit,fixVals,imsize)
        %generates a 2D gaussian with a given patch size, sd, orientation and offset
        % as with gaussian = GenerateGaussian(256,256, 32,32, pi/2,0,0); ishow(gaussian)
        
        p=[0 0 0 0 0];
        p(find(WhichFit))=InParams;
        p(find(~WhichFit))=fixVals(find(~WhichFit));
        p(1) = (abs(p(1)));
        p(2) = (abs(p(2)));
        p(3)  = (p(3)); %don't take absolute of orientation (can be -ve): make sure val is in radians
        p(4) = abs(p(4));
        p(5) = abs(p(5));
        
        xsize = imsize(1);
        ysize = imsize(2);
        [X,Y] = meshgrid(-xsize/2:xsize/2-1,-ysize/2:ysize/2-1);
        X     = X-p(4);% X-xoff;
        Y     = Y-p(5);% Y-yoff;
        
        % speedy variables
        c1=cos(pi-p(3)); %p(3)=theta
        s1=sin(pi-p(3));
        sigX_squared=2*(p(1).^2); %p(1)=sigX
        sigY_squared=2*(p(2).^2); %p(2)=sigY
        
        % rotate co-ordinates
        Xt = X.*c1 + Y.*s1;
        Yt = Y.*c1 - X.*s1;
        
        gauss2D = exp(-(Xt.*Xt)/sigX_squared-(Yt.*Yt)/sigY_squared);%generate 2d gaussian
        gauss2D = (gauss2D./max(All(gauss2D)));
        
        err1=sum(All((gauss2D-data).^2));
        
    end


end
