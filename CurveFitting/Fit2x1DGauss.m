function [sigXEst,sigYEst,oriEst,xoffEst,yoffEst] = Fit2x1DGauss(inImage,fitorientYN,WhichFit,paramVals,anglelims)
% [sigXEst,sigYEst,oriEst,xoffEst,yoffEst] = Fit2x1DGauss(inImage,fitorientYN,WhichFit,paramVals,anglelims)
% fits 2x1D Gaussians to an image with frequency data in an x/y grid
% fits 5 parameters: SDx, SDy, orientation, mean/offsetX and mean/offsetY
% need to input a frequency plot image in 2d (frequency = zaxis), fitorientYN determines whether orientation is fit or assumed to be that which maximises anisotropy
% WhichFit picks parameters to fit, and need paramVals as inputs for any of these. anglelims sets the limits of angle searches e.g. [-20 20]
% e.g.    load('/Users/jgreenwood/MatlabFiles/Curve Fitting/2DGaussTestData3.mat'); [sizey sizex] = size(inImage2); [sigXEst,sigYEst,oriEst,xoffEst,yoffEst] = Fit2x1DGauss(inImage2,1,[1 1 1 1 1],0,[-10 10]);
% cont'd: [ellX ellY] = DrawEllipsePerim(xoffEst+(sizex/2),yoffEst+sizey/2,max([sigXEst sigYEst])*1.28,min([sigXEst sigYEst])*1.28,(oriEst),50); ishow(inImage); hold on; plot(ellX,ellY,'r-')
% or:     gaussian = GenerateGaussian(sizex,sizey,sigXEst,sigYEst,deg2rad(oriEst),xoffEst,yoffEst); ishow(gaussian+inImage)

opt = optimset(optimset,'MaxFunEvals',1000,'Display','off','TolFun',10e-4);%,'LargeScale','off');

[sizey sizex] = size(inImage);
angles        = linspace(anglelims(1),anglelims(2),(anglelims(2)-anglelims(1))+1); %angles of rotation to test (between +/- anglelims where +45 is top right)
for aa=1:length(angles)-1
    fitImage                      = imrotate(inImage,angles(aa),'crop')./max(All(inImage)); %rotate and normalise image to 0-1
    [cx(aa),cy(aa),sx(aa),sy(aa)] = centerofmass(fitImage); %gives an estimate of centre x/y and variation x/y
    xmin       = find(sum(fitImage,1),1);
    xmax       = find(sum(fitImage,1),1,'last' );
    xrange(aa) = xmax-xmin;
    ymin       = find(sum(fitImage,2),1);
    ymax       = find(sum(fitImage,2),1,'last' );
    yrange(aa) = ymax-ymin;
    errRan(aa) = sum(xrange(aa)-yrange(aa));%want to maximise the anisotropy to find the right orientation if there's an ellipse there (look for biggest error on the x-axis
end
rotMax    = max(errRan);
ori       = deg2rad(angles(find(errRan==rotMax))); %guess for rotation of the image in radians
[oo,oind] = min(abs(ori)); %find the closest value to zero (if multiple are present)
oriGuess  = ori(oind); %take a single value to avoid multiples

[cx,cy,sx,sy] = centerofmass(inImage); %gives an estimate of centre x/y and variation x/y
cx=cx-0.5*sizex;%express as plus/minus centre
cy=cy-0.5*sizey;

%remake fitIm - less memory than storing all of the above?
fitImage                      = imrotate(inImage,rad2deg(oriGuess),'crop')./max(All(inImage)); %rotate and normalise image to 0-1
Xdata = (sum(fitImage,1)./max(sum(fitImage,1))); %take normalised X-axis values for most anisotropic image orientation
Ydata = (sum(fitImage,2)./max(sum(fitImage,2)))'; %take normalised Y-axis values for most anisotropic image orientation

[ux,sx,scalex,offx] = FitGaussian((1:numel(Xdata))-0.5*sizex,Xdata,[1 1 1 0],0); %fit gaussian to xdata
[uy,sy,scaley,offy] = FitGaussian(-((1:numel(Ydata))-0.5*sizey),Ydata,[1 1 1 0],0); %fit gaussian to ydata ,note inverted y-axis

defVals=[sx sy oriGuess cx cy]; % Default parameters for fit
fixVals=defVals; % Parameters that will be filled in in the absence of user-provided values

if ~exist('WhichFit') % If the user didn'y specify which parmeters to fit...
    WhichFit=[1 1 1 1 1]; % ... assume they want to fit everything
end

if ~fitorientYN %use oriGuess all the time
    WhichFit = [1 1 0 1 1];
    sendImage = fitImage; %send rotated image to be fit
    paramVals = oriGuess;
else
    sendImage = inImage; %send normal image
end

guess1=defVals(find(WhichFit)); % Initial guess for the parmeters to be fit
if exist('paramVals')
    fixVals(find(~WhichFit))=paramVals; % If user gave us some fixed params slot them into fixVals
end

[pOut,err1] = fminsearch(@gFitFun,guess1,opt,sendImage,WhichFit,fixVals,[sizex sizey],fitorientYN,anglelims); % Does the fit (input whole array of rotated images, used to be just inImage)

% Make a list of the all the fit and fixed params
estParams=[0 0 0 0 0];
estParams(find(WhichFit))=pOut;
estParams(find(~WhichFit))=fixVals(find(~WhichFit));

sigXEst = (abs(estParams(1))); %x error
sigYEst = (abs(estParams(2))); %y error
oriEst  = rad2deg(estParams(3)); %don't take absolute of orientation (can be -ve) %rad2deg(oriGuess);%
xoffEst = (estParams(4)); %x mean
yoffEst = (estParams(5)); %y mean

%%
    function err1=gFitFun(InParams,data,WhichFit,fixVals,imsize,fitorientYN,anglelims) %,angles)
        %generates a 2D gaussian with a given patch size, sd, orientation and offset
        % as with gaussian = GenerateGaussian(256,256, 32,32, pi/2,0,0); ishow(gaussian)
        
        p=[0 0 0 0 0];
        p(find(WhichFit))=InParams;
        p(find(~WhichFit))=fixVals(find(~WhichFit));
        p(1) = abs(p(1));%x error
        p(2) = abs(p(2));%y error
        temp = (p(3)); %don't take absolute of orientation (can be -ve): make sure val is in radians
        temp(temp>deg2rad(anglelims(2)))=deg2rad(anglelims(2)); %round to max possible value
        temp(temp<deg2rad(anglelims(1)))=deg2rad(anglelims(1)); %round to min possible value
        p(3) = temp;
        p(4) = (p(4));%x mean
        p(5) = (p(5));%y mean
        
        xsize = imsize(1);
        ysize = imsize(2);
        %[X,Y] = meshgrid(-xsize/2:xsize/2-1,-ysize/2:ysize/2-1);
        %X     = X-p(4);% X-xoff;
        %Y     = Y-p(5);% Y-yoff;
        
        %imInd = find(angles==(int16(rad2deg(p(3))))); %convert rad to deg and make integer to find index for image
        %fitdata = data(:,:,imInd(1));%select image for rotation
        if fitorientYN
            fitdata = imrotate(data,rad2deg(p(3)),'crop')./max(All(data)); %rotate and normalise image to 0-1
        else
            fitdata = data;
        end
        
        Xdata = (sum(fitdata,1)./max(sum(fitdata,1))); %take normalised X-axis values for most anisotropic image orientation
        Ydata = (sum(fitdata,2)./max(sum(fitdata,2)))'; %take normalised Y-axis values for most anisotropic image orientation
        X     = (1:numel(Xdata))-0.5*xsize;
        Y     = (1:numel(Ydata))-0.5*ysize;
        
        %[ux,sx,scalex,offx] = FitGaussian((1:numel(Xdata))-0.5*sizex,Xdata,[1 1 1 1],1); %fit gaussian to xdata
        %[uy,sy,scaley,offy] = FitGaussian(-(1:numel(Ydata))-0.5*sizey,Ydata,[1 1 1 1],1); %fit gaussian to ydata ,note inverted y-axis
        
        xGauss = DrawGaussian(X,p(4),p(1),1,0);
        yGauss = DrawGaussian(Y,p(5),p(2),1,0);
        xGauss = (xGauss./max(All(xGauss)));
        yGauss = (yGauss./max(All(yGauss)));
        err1=sum(All(([xGauss-Xdata yGauss-Ydata]).^2));
        
        %[ellX ellY] = DrawEllipsePerim(p(4)+(xsize/2),p(5)+(ysize/2),max([p(1:2)])*1.28,min(p(1:2))*1.28,rad2deg(p(3)),50); ishow(inImage); hold on; plot(ellX,ellY,'r-')
        %pause(0.2);
    end


end
