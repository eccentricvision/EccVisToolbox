%MakeHalfMoon
%J Greenwood August 2018
%code that uses DrawCirc to make a halfmoon stimulus on a gray background

MoonRad   = 100; %radius
PatchSize = 300; %image size
MoonRot   = 45;  %moon orientation

circIm  = DrawCirc(MoonRad,[180 360]-MoonRot,PatchSize,PatchSize); 
circ2   = DrawCirc(MoonRad,[0 360],PatchSize,PatchSize);
circInd = find(circ2==1);

MoonIm          = zeros(PatchSize,PatchSize)+0.5;
MoonIm(circInd) = circIm(circInd);

imshow(MoonIm);