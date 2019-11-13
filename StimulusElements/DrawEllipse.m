function ImEll = DrawEllipse(a,b,horpow,verpow,px,py)
% Ellipse(a) creates a Circle with
% diameter == ceil(2*a)
% e.g. ImEll = DrawEllipse(20,40,2,2,60,100); imshow(ImEll)
%
% Ellipse(a,b) creates an Ellipse with
% horizontal axis == ceil(2*a) and vertical axis == ceil(2*b)
%   
% Ellipse(a,b,power) generates a superEllipse according to the
% geometric formula (x./a).^power + (y./b).^power < 1
%
% Ellipse(a,b,horpow,verpow) generates a generalized superEllipse according
% to the geometric formula(x./a).^horpow + (y./b).^verpow < 1
%
% For more info on superEllipses, see
%   http://en.wikipedia.org/wiki/SuperEllipse
%
% Ellipse returns a boolean matrix which is true for all
% points on the surface of the Ellipse and false elsewhere

%px/py are patch dimensions

% DN 2008
% DN 2009-02-02 Updated to do Circles and input argument handling more
%               efficiently
%modified by JG 2010 and name changed to give background control
%e.g. im = DrawEllipse(100,20,2,2,220,220); imshow(im)

error(nargchk(1, 6, nargin, 'struct'));

if nargin < 2
    b = a;
end
if nargin < 3
    horpow = 2;
end
if nargin < 4
    verpow = horpow;
end
if nargin < 6
    px = a;
    py = b;
end
    
a       = a + .5;                     % to produce a Ellipse with horizontal axis == ceil(2*hor semi axis)
b       = b + .5;                     % to produce a Ellipse with vertical axis == ceil(2*vert semi axis)

halfpx = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired
halfpy = round(py/2)-0.5;
[x,y]  = meshgrid(-halfpx:halfpx,-halfpy:halfpy);

ImEll    = abs(x./a).^horpow + abs(y./b).^verpow  < 1;
