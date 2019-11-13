function cArrayIm=DrawCircArrayMultiCon(px,py,circX,circY,circCon,CircRad)
%circIm=DrawCircArrayMultiCon(px,py,circX,circY,circCon,CircRad)
%function to draw an array of circles within a patch with variable contrast levels
%px/py = patch dimensions, circX/circY = centre locations of circles,CircRad = radius of circles
%works well in conjunction with AnnulusArrayPositions to work out max number of circles that can fit into an annulus
%contrast values start from the 0deg position (rightwards) and work CCW around the circle and then go from inner to outer radii progressively
%
%e.g. cArrayIm = DrawCircArrayMultiCon(128,128,[112 100 72 39 18 19 40 73 101],[64 94 111 105 80 47 22 16 33],[-1 -0.4 0.8 0.3 0.1 -0.3 -0.4 1 0.2],16); ishow(cArrayIm)
%eg2. [xVal,yVal,AnnuliRad,NumCirc]=AnnulusArrayPositions(400,400,50,150,5,10,0,0);cArrayIm = DrawCircArrayMultiCon(400,400,xVal+200,yVal+200,[ones(1,NumCirc(1))*0.2 ones(1,NumCirc(2))*0.4 ones(1,NumCirc(3))*0.6 ones(1,NumCirc(4))*0.8 ones(1,NumCirc(5))],10); imshow(cArrayIm)
%eg3. [xVal,yVal,AnnuliRad,NumCirc]=AnnulusArrayPositions(400,400,50,150,5,10,0,1);cArrayIm = DrawCircArrayMultiCon(400,400,xVal+200,yVal+200,[ones(1,NumCirc(1)/2)*0.2 ones(1,NumCirc(1)/2)*-0.2 ones(1,NumCirc(2)/2)*0.4 ones(1,NumCirc(2)/2)*-0.4 ones(1,NumCirc(3)/2)*0.6 ones(1,NumCirc(3)/2)*-0.6 ones(1,NumCirc(4)/2)*0.8 ones(1,NumCirc(4)/2)*-0.8 ones(1,NumCirc(5)/2) -ones(1,NumCirc(5)/2)],10); ishow(cArrayIm)
%eg4. [xVal,yVal,AnnuliRad,NumCirc]=AnnulusArrayPositions(400,400,50,150,5,10,0,0);cArrayIm = DrawCircArrayMultiCon(400,400,xVal+200,yVal+200,[randn(1,sum(NumCirc))],10); ishow(cArrayIm)
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
    cArrayIm(r<CircRad & (th>=0 & th<=360))=1.*circCon(cc); %draw contrast values for that circle within its boundaries
end