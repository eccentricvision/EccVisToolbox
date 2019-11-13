function [xval gab1] = DoGaussFirstDeriv(Params,xval)
%DoGaussFirstDeriv
%e.g. [xval gab1] = DoGaussFirstDeriv([0.5 5 10],[-10:1:10]); plot(xval,gab1)

mean   = Params(1);%where zero-point of the function lies
sigma  = Params(2); %sigma = 10;
maxval = Params(3);
%offset = Params(3);

%t = -40:40; % row vector
xval = xval(:);%+offset; % column vector (could cheat with offset of xval to alter zero point)

% Scale the t-vector, what we actually do is H( t/(sigma*sqrt2) ), where H() is the  Hermite polynomial. 
%x = t / (sigma*sqrt(2));

%basegauss = exp(- xval.^2 / (2*(sigma^2))); % Calculate the gaussian, it is unnormalized. We'll normalize at the end.
basegauss = NormalPDF(xval,mean,sigma^2); % Calculate the gaussian,
gab1 = (-1).^1.*(2*xval).*basegauss; % apply Hermite polynomial to gauss (1st derivative)
gab1 = -gab1;
gab1 = (gab1/max(gab1))*maxval; %normalise and set to maximum value of dataset required

%plot(xval,gab1);
