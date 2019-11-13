function logbar(h,bmin)
%LOGBAR Transform a bar plot to semilogy
% LOGBAR(H,BMIN) changes the bar plot so that each bar's
% bottom is at BMIN. The argument H may be either the
% axis handle or one of the handles from BAR.
% The bar plot's y-scale is changed to log.
%
% Both arguments are optional. The default H is GCA and
% the default BMIN is EPS.
%
% See also BAR, GCA, EPS. SET

% $Author: tdg $ $Revision: 1.2 $ $Date: 2000/04/22 00:07:05 $
% $Locker: tdg $ (tdg = Troy D. Goodson)
% Troy.D.Goodson@jpl.nasa.gov

% take care of default settings
if nargin < 2, bmin = []; end
if nargin < 1, h = []; end
if isempty(h), h = gca; end
if isempty(bmin), bmin = eps; end

% if user gave axes handles, then assemble a list of
% all children who are patches
if ( get(h(1),'type') == 'axes' )
   h2 = h;
   h = [];
   for ii = 1:length(h2)
      h = [h; findobj(h2(ii),'type','patch')];
      % We know the user wants this axis to be a semilogy plot
      set(h2(ii),'yscale','log')
   end
end

% assume that "h" is a list of patches
for ii = 1:length(h)
   hy = get(h(ii),'vertices');
   % set all zero-entries to BMIN
   hy( find( hy == 0 ) ) = bmin;
   set(h(ii), 'vertices', hy)
end

% In case the user sent handles to patches, change the patch
% parent (better be an axes) to semilogy
set(get(h(1),'parent'),'yscale','log')

return
