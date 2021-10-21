function RectIm = DrawKanizsaRect(PatchX,PatchY,RectSizeX,RectSizeY,CircRad,CircRot,PhysContour,LineWidth)
%function RectIm = DrawKanizsaRect(PatchX,PatchY,RectSizeX,RectSizeY,CircRad,CircRot,PhysContour,LineWidth);
%DrawKanizsaRect.m
%
%function to make illusory 'Kanizsa' Rectangle with or without rotation
%similar to Ringach & Shapley (1996)
%can be purely illusory contours or with a physical contour traced around the rectangle (using a parabolic function)
%inputs: PatchX,PatchY = dimensions of image patch
% RectSizeX,RectSizeY = centre-to-centre distance for PacMan/Circle elements on corners of the illusory rectangle
% CircRad = radius of PacMan/circle elements
% CircRot = rotation of PacMan/circle elements with reference to the
% top-left element (as in R&S 1996): -ve makes pinched/thin, +ve makes pulled/fat
% PhysContour = 0/1 where 0=illusory rectangle, 1=physical contour drawn (using a parabolic function fit to the image)
% LineWidth = width of physical contour if present (extending outwards from centre of image)
%
%J Greenwood w/ Jade Bouffard, October 2021
%
% e.g.: RectIm = DrawKanizsaRect(1000,1000,200,400,60,-10,0,NaN); imshow(RectIm)
% e.g2: RectIm = DrawKanizsaRect(1000,1000,200,400,60,10,1,3); imshow(RectIm)

%clear all;
%circle and kanizsa rectangle parameters (now set by function input)
% PatchX      = 1000;
% PatchY      = 1000;
% RectSizeX   = 200;
% RectSizeY   = 400;
% CircRad     = 60;
% CircRot     = 5; %>0 makes a 'pinched-X / thin' shape <0 makes 'bulged-X / fat' shape, same as Ringach & Shapley (1996)
% PhysContour = 0; %0=illusory contour, 1=physical contour
% LineWidth   = 3; %if physical contour present - how many pixels thick?

CircPatch   = (CircRad+1)*2;

%draw circle locations - top-right,top-left,bottom-left,bottom-right (45 135 225 315)
CircOffsetX = round([RectSizeX/2 -RectSizeX/2 RectSizeX/2 -RectSizeX/2 ]);
CircOffsetY = round([-RectSizeY/2 -RectSizeY/2 RectSizeY/2 RectSizeY/2]); %NB inverted Y
if mod(PatchX,2) %odd number
    halfpx = round(PatchX/2)-1; %to keep number of pixels the same as desired
else %even number
    halfpx = (PatchX/2)-0.5; %-0.5 to keep number of pixels the same as desired
end
if mod(PatchY,2) %odd number
    halfpy = round(PatchY/2)-1; %to keep number of pixels the same as desired
else %even number
    halfpy = (PatchY/2)-0.5;
end
CircCentX   = halfpx+CircOffsetX;
CircCentY   = halfpy+CircOffsetY;

CircAng     = [180-CircRot 270+CircRot 90+CircRot 0-CircRot]; %top-right,top-left,bottom-left,bottom-right (45 135 225 315)

RectIm = zeros(PatchY,PatchX);
for cc=1:4
    CircIm = imrotate(DrawCirc(CircRad,[0 270],CircPatch,CircPatch),CircAng(cc),'nearest','crop'); %draw the rotated circle
    RectIm(round(CircCentY(cc)-CircPatch/2):round(CircCentY(cc)+CircPatch/2)-1,round(CircCentX(cc)-CircPatch/2):round(CircCentX(cc)+CircPatch/2)-1) = CircIm;  %place the circle in location on the rectangle image patch
end

%% add physical contours (if requested)

if PhysContour==1 %physical contour only
    %start from CircOffsetX and Y, then extrapolate outwards by radius and
    %CircRot angle to get outer points of the PacMan elements
    
    %set angles for endpoints of the PacMan mouths
    %NB circle locations - %top-right,top-left,bottom-left,bottom-right (45 135 225 315)
    MouthAng(1,:)     = [90+CircRot 90-CircRot 270-CircRot 270+CircRot]; %vertical edges of mouth
    MouthAng(2,:)     = [180+CircRot 0-CircRot 180-CircRot 0+CircRot]; %horizontal edges of mouth
    
    MouthAng(MouthAng<0)=MouthAng(MouthAng<0)+360;
    MouthAng(MouthAng>360)=MouthAng(MouthAng<0)-360;
    
    %set locations for endpoints of the PacMan mouths
    for cc=1:4 %for each circle
        for ang=1:2 %vertical then horizontal edges
            PacMouthLocX(ang,cc) = round(CircOffsetX(cc) + cos(deg2rad(MouthAng(ang,cc))).*CircRad);
            PacMouthLocY(ang,cc) = -round(-CircOffsetY(cc) - sin(deg2rad(MouthAng(ang,cc))).*CircRad); %y-dimension %note inverted y!
        end
    end
    
    %next generate linspace values for the horizontal and vertical lines separately
    %vertical lines
    LineX(1,:,1) = [linspace(CircOffsetX(1),PacMouthLocX(1,1),5) linspace(PacMouthLocX(1,3),CircOffsetX(3),5)]; %right-hand line X
    LineY(1,:,1) = [linspace(CircOffsetY(1),PacMouthLocY(1,1),5) linspace(PacMouthLocY(1,3),CircOffsetY(3),5)]; %right-hand line Y
    LineX(2,:,1) = [linspace(CircOffsetX(2),PacMouthLocX(1,2),5) linspace(PacMouthLocX(1,4),CircOffsetX(4),5)]; %left-hand line X
    LineY(2,:,1) = [linspace(CircOffsetY(2),PacMouthLocY(1,2),5) linspace(PacMouthLocY(1,4),CircOffsetY(4),5)]; %left-hand line Y
    %horizontal lines
    LineX(1,:,2) = [linspace(CircOffsetX(1),PacMouthLocX(2,1),5) linspace(PacMouthLocX(2,2),CircOffsetX(2),5)]; %top line X
    LineY(1,:,2) = [linspace(CircOffsetY(1),PacMouthLocY(2,1),5) linspace(PacMouthLocY(2,2),CircOffsetY(2),5)]; %top line Y
    LineX(2,:,2) = [linspace(CircOffsetX(3),PacMouthLocX(2,3),5) linspace(PacMouthLocX(2,4),CircOffsetX(4),5)]; %bottom line X
    LineY(2,:,2) = [linspace(CircOffsetY(3),PacMouthLocY(2,3),5) linspace(PacMouthLocY(2,4),CircOffsetY(4),5)]; %bottom line Y
    
    %for thickening line
    if LineWidth>1
        %halfwidth = floor(LineWidth/2);
        thickvals(1,:) = 0:1:LineWidth-1;%-halfwidth:1:halfwidth;
        thickvals(2,:) = -(LineWidth-1):1:0;%-halfwidth:1:halfwidth;
    else
        %halfwidth = 0; %no thickening
        thickvals = 1;
    end
    
    % fit to parabola
    %vert line %need to reverse x,y and then rotate it
    [m,b]=FitParabola(LineY(1,:,1),LineX(1,:,1),[1 1],[]);
    VertY = min(LineY(:)):1:max(LineY(:));
    VertX = DrawParabola(VertY,m,b);
    %make the other side (just reverse X axis)
    VertY(2,:) = VertY(1,:);
    VertX(2,:) = -VertX(1,:);
    %horizontal line
    [m,b]=FitParabola(LineX(1,:,2),LineY(1,:,2),[1 1],[]);
    HorzX = min(LineX(:)):1:max(LineX(:));
    HorzY = DrawParabola(HorzX,m,b);
    %make the other side (just reverse Y axis)
    HorzX(2,:) = HorzX(1,:);
    HorzY(2,:) = -HorzY(1,:);
    
    VertX = round(VertX);
    VertY = round(VertY);
    HorzX = round(HorzX);
    HorzY = round(HorzY);
    
    %plot to check
    %     figure; plot(PacMouthLocX,PacMouthLocY,'o',CircOffsetX,-CircOffsetY,'ko'); axis equal
    %     hold on; plot(VertX',VertY','r-'); plot(HorzX',HorzY','k-');
    
    %find line locations in meshgrid
    Tol             = 1; %tolerance for equality checks
    [meshpx,meshpy] = meshgrid(-halfpx:halfpx,-halfpy:halfpy); %coordinates for rectangle patch
    meshpx=round(meshpx); meshpy=round(meshpy); %make sure integer values used for ease of localisation
    %    [meshpx,meshpy] = meshgrid(-(RectPatchX/2):(RectPatchX/2)-1,-(RectPatchY/2):(RectPatchY/2)-1); %coordinates for rectangle patch - keep integers
    for ll=1:2
        %vertical lines
        for pp=1:numel(VertY(1,:))
            if ~isempty(find(abs(meshpx-VertX(ll,pp))<Tol & abs(meshpy-VertY(ll,pp))<Tol)) %skip mismatched pixels
                [PixY,PixX] = find(abs(meshpx-VertX(ll,pp))<Tol & abs(meshpy-VertY(ll,pp))<Tol);
            end
            
            for hh=1:numel(thickvals(ll,:))
                RectIm(PixY,PixX+thickvals(ll,hh)) = 1;%colour in relevant pixel
            end
        end
        %horizontal lines
        for pp=1:numel(HorzY(1,:))
            if ~isempty(find(abs(meshpx-HorzX(ll,pp))<Tol & abs(meshpy-HorzY(ll,pp))<Tol)) %skip mismatched pixels
                [PixY,PixX] = find(abs(meshpx-HorzX(ll,pp))<Tol & abs(meshpy-HorzY(ll,pp))<Tol);
            end
            for hh=1:numel(thickvals(ll,:))
                RectIm(PixY+thickvals((2-ll)+1,hh),PixX) = 1;%colour in relevant pixel
            end
            
        end
    end
end

RectIm = 1-RectIm; %standard is for black circles on white BG

%% plot

%RectIm = RectIm+(randn(RectPatchY,RectPatchX)*3)

% figure;
% imshow(RectIm);
