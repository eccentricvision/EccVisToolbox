function r = xlim(arg1, arg2)

if nargin < 2, arg2 = []; end
if nargin < 1, arg1 = []; end
arg = cat(2, arg1(:)', arg2(:)');
if ~isempty(arg), 
   lasterr('')
   eval('set(gca, ''xlim'', sort(arg))', '');
   if ~isempty(lasterr), error('illegal arguments'), end
end
if nargout, r = get(gca, 'xlim'); end