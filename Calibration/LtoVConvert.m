function [res]=LtoVConvert(LR,im,BitsYN)
%converts luminance values (0-1) for the psychtoolbox, with gamma correction, either with or without the BitsBox
%eg. [res] = LtoVConvert(LR,0.5,1); %uses Bitsbox
%BitsYN 0 = no, 1 =yes

if BitsYN
    res=zeros(size(im,1),size(im,2),3,'double');
    %im2=zeros(size(im,1),size(im,2),'uint16');

    im2=real((LR.LtoVfun(LR,im)));
    %im2 =(im-LR.LMin).*( LR.VMax/(LR.LMax-LR.LMin));

    res(:,:,1)=floor(im2./256); 					    % Write MSB ramp into red...
    res(:,:,2)=floor(mod(im2,256)); 				    % ... and LSB ramp into green
    res=squeeze(res);
else
    res=zeros(size(im,1),size(im,2),3,'double');
    
    im2=(uint8(LR.LtoVfun(LR,im)));
    res(:,:,1)=im2; %convert to three RGB values for consistency across code (because psychtoolbox uses 3D arrays for RGB input)
    res(:,:,2)=im2; 
    res(:,:,3)=im2; 
end
res(res>255)=255; %clip to upper range to avoid impossible luminances
res(res<0)=0; %clip lower range

end
