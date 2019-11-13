function landIm=DrawLandoltC(rad,orient,px,py,con)
%landIm=DrawLandoltC(rad,orient,px,py,con)
%function to draw a Landolt-C stimulus centred within a patch
%inputs: rad = radius; orient = where the gap is (0=right,90=up,etc) px/py = patch dimensions,con = contrast (0-1)
%NB width of Landolt C stroke is always 1/5 the diameter
%NB due to meshgrid setup gap width can only progress in increments of 2
%pixels (recommend drawing at 2x required size and reducing in PTB for stimulus presentation)
%e.g. landIm = DrawLandoltC(100,0,240,320,0.75); imshow(landIm)
%J Greenwood 2011

halfpx = round(px/2)-0.5; %-0.5 to keep number of pixels the same as desired (and centre stimulus in middle with even pixels)
halfpy = round(py/2)-0.5;

[meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle
[th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates

feat_width = (rad/2.5); %(width of Landolt-C always 1/5 diameter)
rad_in = rad-(feat_width); %radius of inner circle to make ring
landIm = meshpx.*0; %create blank array
landIm(r<=rad & r>=rad_in)=1; %draw 1s within rectangle boundaries

halfgap = (rad/5); %make gap in 'C'
gapInd  = find(meshpx>0 & meshpy>=-halfgap & meshpy<=halfgap);
landIm(gapInd) = zeros(size(landIm(gapInd)));
if orient>0
    landIm = imrotate(landIm,orient,'crop'); %rotate if required
end
landIm = landIm.*con;