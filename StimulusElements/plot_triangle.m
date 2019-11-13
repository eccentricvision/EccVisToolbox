function plot_triangle(xt,yt,length)

% Triangle is defined by 3 points
% point A1 : xt(1),yt(1)
% point A2 : xt(2),yt(2)
% point A3 : xt(3),yt(3)

% length : simple case where the image is a square of length "length".

% exemple :
% x = [2;70;56];
% y = [100;110;45];
% plot_triangle(x,y,140)

% check which point has the highest y-coordinate
[c,i]=max(yt);

% re-arrange the coordinates data with y(1)=yt(i)
% point B1 : x(1),y(1)
% point B2 : x(2),y(2)
% point B3 : x(3),y(3)

if i==1
    x=xt;
    y=yt;
elseif i==2
    x(1)=xt(2);
    y(1)=yt(2);
    x(2)=xt(1);
    y(2)=yt(1);
    x(3)=xt(3);
    y(3)=yt(3);
elseif i==3
    x(1)=xt(3);
    y(1)=yt(3);
    x(2)=xt(1);
    y(2)=yt(1);
    x(3)=xt(2);
    y(3)=yt(2);
end

% set a black background to the image

xx(1) = 0;
yy(1) = length;
xx(2) = length;
yy(2) = length;

area(xx,yy,'FaceColor','k','EdgeColor','k')

hold on

% plot of the first area defined by the segment [B2B1] and [B1B3]
% color white

xx(1) = x(2);
yy(1) = y(2);
xx(2) = x(1);
yy(2) = y(1);
xx(3) = x(3);
yy(3) = y(3);

area(xx,yy,'FaceColor','w','EdgeColor','k')

hold on

% plot of the first area defined by the segment [B2B3]
% color black

xx(1) = x(2);
yy(1) = y(2);
xx(2) = x(3);
yy(2) = y(3);

area(xx,yy,'FaceColor','k','EdgeColor','k')

% size of the image
xlim([0 length])
ylim([0 length])

box off
axis off

end

%%%%%%%%%%%%
