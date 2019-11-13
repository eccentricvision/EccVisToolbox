function cArrayIm=DrawCircArray(px,py,circX,circY,CircRad)
%circIm=DrawCircArray(px,py,circX,circY,CircRad)
%function to draw an array of circles within a patch
%px/py = patch dimensions, circX/circY = centre locations of circles,CircRad = radius of circles
%works well in conjunction with AnnulusArrayPositions to work out max number of circles that can fit into an annulus
%
%e.g. cArrayIm = DrawCircArray(128,128,[112 100 72 39 18 19 40 73 101],[64 94 111 105 80 47 22 16 33],16); imshow(cArrayIm)
%J Greenwood 2015

halfpx = round(px/2)-0.5; %centre position and size of half the array
halfpy = round(py/2)-0.5;

for cc=1:numel(circX);
    circXshift = circX(cc)-halfpx;
    circYshift = circY(cc)-halfpy;
    
    [meshpx,meshpy] = meshgrid(-halfpx-circXshift:halfpx-circXshift,-halfpy-circYshift:halfpy-circYshift); %coordinates for rectangle
    
    [th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates
    th(th<0)=th(th<0)+(2*pi);%th(th<180)=wrapTo2pi(th); %wrap to 0-360
    if cc==1
        cArrayIm = meshpx.*0; %create blank array
    end
    cArrayIm(r<CircRad & (th>=0 & th<=360))=1; %draw 1s within rectangle boundaries
end