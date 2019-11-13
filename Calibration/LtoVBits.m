function [res]=LtoVBits(LR,im)

res=zeros(size(im,1),size(im,2),3,'double');
im2=zeros(size(im,1),size(im,2),'uint16');

im2=real((LR.LtoVfun(LR,im)));
%im2 =(im-LR.LMin).*( LR.VMax/(LR.LMax-LR.LMin));

res(:,:,1)=floor(im2./256); 					    % Write MSB ramp into red...
res(:,:,2)=floor(mod(im2,256)); 				    % ... and LSB ramp into green
res=squeeze(res);
res(res>255)=255; %clip to upper range to avoid impossible luminances
res(res<0)=0; %clip lower range
