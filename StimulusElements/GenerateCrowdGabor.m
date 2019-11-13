function gaborarray = GenerateCrowdGabor(bigpatch, gabpatch, sigma, theta2, lambda,phase,con)
% gaborarray = GenerateCrowdGabor(800,185, 30,[deg2rad(80) deg2rad(120) deg2rad(90)], 60,0,1); imshow(gaborarray)
%m/n = x/y patch size; sigma1/sigma2 = Gaussian SD values in 2 dimensions
%theta2 = orientation of grating; theta= orientation of Gaussian patch (if aspect ratio appropriate
%lambda = spatial period in pixels; phase=phase!; xoff/yoff= offset of Gaussian midpoint within patch; con=contrast

NumGabs=length(theta2);
gabX(1) = round(bigpatch/2); gabY(1) = round(bigpatch/2);
OrStep=DegToRad(360/(NumGabs-1)); %determines where on clockface flankers are placed - 0deg is right of target, equal steps around the clock for each flank
OStart=0;
Sep=gabpatch;
for i=2:(NumGabs)
    FlankAng=OStart+(i-2)*OrStep; FlankDist=Sep;
    gabX(i)=round(gabX(1)+(cos(FlankAng).*FlankDist))+1;
    gabY(i)=round(gabY(1)+(sin(FlankAng).*FlankDist))+1;
end

gaborarray=zeros(bigpatch,bigpatch);
gabor=zeros(gabpatch,gabpatch,NumGabs);
for gg=1:NumGabs
    gabor(:,:,gg)=GenerateGabor(gabpatch,gabpatch,sigma,sigma,pi/2,theta2(gg),lambda,phase,0,0,con);
    gabposX=[round(gabX(gg)-(0.5*gabpatch)) round(gabX(gg)-(0.5*gabpatch))+(length(gabor(:,:,gg))-1)];
    gabposY=[round(gabY(gg)-(0.5*gabpatch)) round(gabY(gg)-(0.5*gabpatch))+(length(gabor(:,:,gg))-1)];
    gaborarray(gabposY(1):gabposY(2),gabposX(1):gabposX(2))=gabor(:,:,gg);
end
gaborarray=gaborarray+0.5;
