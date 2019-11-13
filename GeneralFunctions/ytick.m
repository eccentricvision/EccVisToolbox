function [tick, label] = ytick(arg, extra)
% YTICK manipulate y-axis tick positions and labels with minimum confusion
% 
% [TICKS LABELS] = YTICK                  % gets y-axis tick positions and labels
% [TICK_MODE LABEL_MODE] = YTICK('mode')  % gets 'YTickMode' and 'YTickLabelMode'
%                                         %                            properties
% YTICK(TICK_POSITIONS)                   % sets y-axis tick positions and resets
%                                         %       y-axis tick labels to automatic
% YTICK(TICK_LABELS)                      % sets y-axis tick labels and locks
%                                         %                 y-axis tick positions
% YTICK('manual')                         % lock y-axis tick positions
% YTICK('auto')                           % resets y-axis tick positions and
%                                         %                   labels to automatic
% YTICK(AX, ...)                          % operates on axes AX instead of GCA
% 
% The main aim of manipulating the interplay between positions, labels and modes
% is to avoid the confusing situation where labels are set manually, and then tick
% positions change (either because the user changes them, or the axes are resized
% while the tick mode is automatic) without the labels being updated - so the
% labels end up labelling the wrong positions. Use YTICK exclusively to manipulate
% tick positions and labels, and this should not happen.

% Part of PFCMP version 2.5.41, an extension to the PSIGNIFIT toolbox for MATLAB versions 5 and up.
% The license and NO WARRANTY statement for PSIGNIFIT also applies to this release - see psych_legal.m
% Copyright (c) J.Hill 2002.
% mailto:psignifit@bootstrap-software.org
% http://www.bootstrap-software.org/psignifit/

if nargin < 2, extra = []; end
if nargin < 1, arg = []; end

ax = [];
if isnumeric(arg) & length(arg) == 1
	if ishandle(arg)
		[ax arg extra] = deal(arg, extra, []);
	end
end
if isempty(ax), ax = gca; end
if ~isempty(extra), error('too many arguments'), end
if isempty(arg)
	tick = get(ax, 'ytick');
	label = get(ax, 'yticklabel');
else
	if iscellstr(arg), arg = char(arg(:)); end
	if isstr(arg)
		switch lower(arg)
		case 'off'
			set(ax, 'ytick', [], 'yticklabelmode', 'auto')
		case 'mode'
			tick = get(ax, 'ytickmode');
			label = get(ax, 'yticklabelmode');
		case 'manual'
			set(ax, 'ytickmode', 'manual')
		case 'auto'
			% release tick positions - they may change, so also release labels
			set(ax, 'ytickmode', 'auto', 'yticklabelmode', 'auto')
		otherwise
			% set the labels and lock the tick positions
			set(ax, 'yticklabel', arg, 'ytickmode', 'manual')
		end
	else
		% set new tick positions and release labels
		set(ax, 'yticklabelmode', 'auto', 'ytick', arg)
	end
end
