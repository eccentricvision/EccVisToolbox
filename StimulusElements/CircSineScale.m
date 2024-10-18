% CIRCSINESCALE  Generates circular sine wave grating
% Can also be use to construct phase congruent patterns
%
% Usage:    im = CircSineScale(sze, wavelength, nScales, ampExponent, offset, p, trim, mult)
%
% Arguments:
%      sze         - The size of the square image to be produced.
%      wavelength  - The wavelength in pixels of the sine wave.
%      nScales     - No of fourier components used to construct the
%                    signal. This is typically 1, if you want a simple sine
%                    wave, or >50 if you want to build a phase congruent
%                    waveform. Defaults to 1.
%      ampExponent - Decay exponent of amplitude with frequency.
%                    A value of -1 will produce amplitude inversely
%                    proportional to frequency (this will produce a step
%                    feature if offset is 0)
%                    A value of -2 with an offset of pi/2 will result in a
%                    triangular waveform.
%                    Defaults to -1;
%      offset      - Phase offset to apply to circular pattern.
%                    This controls the feature type, see examples below.
%                    Defaults to pi/2 if nScales is 1, else, 0
%      p           - Optional parameter specifying the norm to use in
%                    calculating the radius from the centre. This defaults to
%                    2, resulting in a circular pattern.  Large values gives
%                    a square pattern
%      trim        - Optional flag indicating whether you want the
%                    circular pattern trimmed from the corners leaving
%                    only complete cicles. Defaults to 0.
%      mult        - multiplier for the x,y axes to scale up the size of
%                    the rings with distance from the centre
%
% Examples:
% nScales = 1             - You get a simple circular sine wave pattern 
% nScales 50, ampExponent -1, offset 0      - Square waveform
% nScales 50, ampExponent -2, offset pi/2   - Triangular waveform
% nScales 50, ampExponent -1.5, offset pi/4 - Something in between square and
%                                             triangular 
% nScales 50, ampExponent -1.5, offset 0    - Looks like a square but is not.
% NB. when we log-scaled the meshgrid it inverts the effect of the
% amplitude exponent so numbers need to be positive to get a square wave,
% negative gives a sine wave
%
% e.g. im = CircSineScale(800, 20, 50, 2, 0, 2, 0, 2);imshow(im);%, p, trim)
% See also: STARSINE, STEP2LINE


% Copyright (c) 2003-2010 Peter Kovesi
% Modified J Greenwood October 2024 to add multiplier

% May 2003 - Original version
% Nov 2006 - Trim flag added
% Dec 2010 - Ability to construct phase congruent patterns, order of argument
%            list changed

function im = CircSineScale(sze, wavelength, nScales, ampExponent, offset, p, trim, mult)

    if ~exist('trim', 'var'),          trim = 0;          end
    if ~exist('p', 'var'),             p = 2;             end
    if ~exist('ampExponent', 'var'),   ampExponent = -1;  end
    if ~exist('nScales', 'var'),       nScales = 1;       end    
    if ~exist('mult','var'),           mult    = 1;       end %no scaling by default if not specified

    % If we have one scale, hence just making a sine wave, and offset is not
    % specified set it to pi/2 to give cintinuity at the centre
    if nScales == 1 &&  ~exist('offset', 'var')
        offset = pi/2;   
    elseif ~exist('offset', 'var')
        offset = 0;
    end
    
    if mod(p,2)
	error('p should be an even number');
    end
    
    % Place origin at centre for odd sized image, and below and the the
    % right of centre for an even sized image
    if mod(sze,2) == 0   % even sized image
	l = -sze/2;
	u = sze/2-1;
    else
	l = -(sze-1)/2;
	u = (sze-1)/2;
    end
    
    [x,y] = meshgrid(l:u);

    [theta,rad] = cart2pol(x,y); %convert to polar coordinates
    rad         = log10(rad.*mult);%.*(rad.*mult);
    [x,y]       = pol2cart(theta,rad);
%    x     = x.*mult;
%    y     = y.*mult;
    r = (x.^p + y.^p).^(1/p);

    im = zeros(size(r));
    
    for scale = 1:2:(2*nScales-1)
        im = im + scale^ampExponent* sin(scale* r * 2*pi/wavelength + offset); 
    end
    
    if trim     % Remove circular pattern from the 'corners'
	cycles = fix(sze/2/wavelength); % No of complete cycles within sze/2
	im = im.* (r < cycles*wavelength) + (r>= cycles*wavelength);
    end
    
     