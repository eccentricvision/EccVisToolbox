function [X,Y] = DrawEllipsePerim(x, y, majax, minax, angle, steps)
    %# This functions returns points to draw an ellipse
    %#
    %#  @param x     X coordinate
    %#  @param y     Y coordinate
    %#  @param a     Semimajor axis radius
    %#  @param b     Semiminor axis radius
    %#  @param angle Angle of the ellipse (in degrees where -45 is top right)
    %#  modified by John Greenwood 2012
    %#  eg [X Y] = DrawEllipsePerim(5, 10, 5, 10, -45, 30); plot(X,Y,'r-')

    error(nargchk(5, 6, nargin));
    if nargin<6, steps = 36; end

    beta = angle * (pi / 180);
    sinbeta = sin(beta);
    cosbeta = cos(beta);

    alpha = linspace(0, 360, steps)' .* (pi / 180);
    sinalpha = sin(alpha);
    cosalpha = cos(alpha);

    X = x + (majax * cosalpha * cosbeta - minax * sinalpha * sinbeta);
    Y = y + (majax * cosalpha * sinbeta + minax * sinalpha * cosbeta);

    if nargout==1, X = [X Y]; end
end