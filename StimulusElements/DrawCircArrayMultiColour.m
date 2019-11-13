function cArrayIm=DrawCircArrayMultiColour(px,py,circX,circY,circCols,CircRad)
%circIm=DrawCircArrayMultiColour(px,py,circX,circY,circCols,CircRad)
%function to draw an array of circles within a patch with variable contrast levels
%px/py = patch dimensions, circX/circY = centre locations of circles,CircRad = radius of circles
%works well in conjunction with AnnulusArrayPositions to work out max number of circles that can fit into an annulus
%contrast values start from the 0deg position (rightwards) and work CCW around the circle and then go from inner to outer radii progressively
%
%eg. [xVal,yVal,AnnuliRad,NumCirc]=AnnulusArrayPositions(400,400,50,150,5,10,0,0);cArrayIm = DrawCircArrayMultiColour(400,400,xVal+200,yVal+200,[repmat([1 0 0],[sum(NumCirc)/2 1]);repmat([0 1 0],[sum(NumCirc)/2 1])],10); imshow(cArrayIm)
%eg2. [xVal,yVal,AnnuliRad,NumCirc]=AnnulusArrayPositions(400,400,50,150,5,10,0,1);cArrayIm = DrawCircArrayMultiColour(400,400,xVal+200,yVal+200,Shuffle([repmat([1 0 0],[sum(NumCirc)/2 1]);repmat([0 1 0],[sum(NumCirc)/2 1])]')',10); ishow(cArrayIm)
%
%J Greenwood 2015

halfpx = round(px/2)-0.5; %centre position and size of half the array
halfpy = round(py/2)-0.5;

for circ=1:numel(circX);
    circXshift = circX(circ)-halfpx;
    circYshift = circY(circ)-halfpy;
    
    [meshpx,meshpy] = meshgrid(-halfpx-circXshift:halfpx-circXshift,-halfpy-circYshift:halfpy-circYshift); %coordinates for rectangle
    
    [th,r]=cart2pol(meshpx,meshpy); %convert to polar coordinates
    th(th<0)=th(th<0)+(2*pi);%th(th<180)=wrapTo2pi(th); %wrap to 0-360
    
    for cc=1:3 %colour values
        if circ==1
            cArrayIm(:,:,cc) = meshpx.*0; %create blank array
        end
        ctemp = cArrayIm(:,:,cc);
        ctemp(r<CircRad & (th>=0 & th<=360))=1.*circCols(circ,cc); %draw color values for that circle within its boundaries
        cArrayIm(:,:,cc) = ctemp;
    end
end