function rms = RMScontrast(im)
%RMScontrast
%function to work out the Root Mean Square contrast of an image
%input image (im) and rms is calculated
%John Greenwood 2013
%e.g. imageA=imread('kittensquare.tif');imageB=imread('HouseSquare.tif');rmsA=RMScontrast(imageA);rmsB=RMScontrast(imageB);figure;subplot(1,2,1);imshow(imageA);title(num2str(rmsA));subplot(1,2,2);imshow(imageB);title(num2str(rmsB));

im  = double(im); %convert to double floating-point format
if max(im)>1
    im = im./max(im(:)); %have to have values between 0-1
end

%rms = std(im(:))/mean(im(:)); %from Pelli & Bex (2013) Vis Res

%or - from Eli Peli JOSA 1990
num    = (1/(numel(im(:))-1));
sumSQ  = sum((im(:)-mean(im(:))).^2);
rms    = (sqrt(num.*sumSQ))./mean(im(:));

%or - from Bex & Makous (2002) JOSA -> same as Eli Peli's calculations
%num    = numel(im(:));
%sumSQ  = sum(im(:).^2); %sum of L^2
%SQmean = (sum(im(:)).^2)./num;
%rms    = (sqrt((sumSQ-SQmean)./num))./mean(im(:));

%or from Wikipedia - Contrast_(Vision)
%rms = sqrt((1./numel(im(:))).*((sum(im(:)-mean(im(:)))).^2));