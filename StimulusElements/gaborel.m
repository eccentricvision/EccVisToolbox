function gb=gaborel(sigma_x,sigma_y,theta,lambda,psi,gamma)
 
sz_x=fix(6*sigma_x);
if mod(sz_x,2)==0, sz_x=sz_x+1;end
 
 
sz_y=fix(6*sigma_y);
if mod(sz_y,2)==0, sz_y=sz_y+1;end
 
[x y]=meshgrid(-fix(sz_x/2):fix(sz_x/2),fix(-sz_y/2):fix(sz_y/2));
 
% Rotation 
x_theta=x*cos(theta)+y*sin(theta);
y_theta=-x*sin(theta)+y*cos(theta);
 
gb=exp(-.5*(x_theta.^2/sigma_x^2+gamma^2*y_theta.^2/sigma_y^2)).*cos(2*pi/lambda*x_theta+psi);