
function crosses=MakeSubPixCross2(dim,pdim,propWidth,offX,offY,or1,or2,c1,c2,sumcons)
% f1=MakeSubPixCross2(55,[64 124],5,0,1,3,0,0.25,0.75);  figure; imshow(f1)
%can now put in multiple values at once to generate a multi array of cross images
%number is determined by length of [offX] variable, plus [offY],[or1],[or2],[c1],[c2])
% f1=MakeSubPixCross2([55 55],64,5,[0 0 0],[0 0 0],deg2rad([0 45 45]),deg2rad([0 0 0]),[1 1 1],[1 1 1]); figure; subplot(1,3,1);imshow(f1(:,:,1));subplot(1,3,2);imshow(f1(:,:,2));subplot(1,3,3);imshow(f1(:,:,3));

%dim = cross dimensions, pdim = patch dimensions, propWidth = proportion of
%image width taken up by line, offX offY = offset of line in pixels
if ~exist('c1')
    c1=1;
end
if ~exist('c2')
    c2=1;
end
if length(pdim)<2 %if only single input for patch dimensions
    pdim(2)=pdim(1); %repeat
end
imX=zeros(dim,1);
imY=zeros(dim,1);
linethick=floor(dim/propWidth); %makes line thickness a fixed proportion of image dimensions

xs=round((dim/2)-linethick/2);
ys=round((dim/2)-linethick/2);
imX(xs+1:xs+linethick)=1;
imY(ys+1:ys+linethick)=1;

fim =PadIm(repmat(imX,[1 dim]),[pdim(2) pdim(1)],0); %adds extra background to each line stimulus (black background)
fim2=PadIm(repmat(imY',[dim 1]),[pdim(2) pdim(1)],0); %note matrix transposition to make horizontal line

for cc=1:length(offX)
    fimR  = ImClip(imrotate(fim,RadToDeg(or1(cc)),'bilinear'),[pdim(2) pdim(1)]); %rotates each element
    fimR  = ImShift(fimR,offY(cc),pi/2); %input is (image, npixels to shift, dirn to shift)
    fimR2 = ImClip(imrotate(fim2,RadToDeg(or2(cc)),'bilinear'),[pdim(2) pdim(1)]);
    fimR2 = ImShift(fimR2,offX(cc),pi);

    %fim3=fimR+fimR2;
    fim3=(c1(cc).*fimR)+(c2(cc).*fimR2); %adds elements together
    sumcons = 1; %sum contrasts where overlap
    summax  = 1; %overlay maximum contrast on minimum (or viceversa for 0)
    if sumcons
        if c1(cc)==c2(cc)
            %don't do anything - otherwise leads to aliasing issues (and no need to sum anyway)
        else
            fimcon  = round(abs(100*c1(cc).*fimR))+(abs(100*c2(cc).*fimR2)); %adds abs elements together
            if summax
                conval = max([c1(cc) c2(cc)]); convalsub = min([c1(cc) c2(cc)]); %take max contrast
            else
                conval = min([c1(cc) c2(cc)]); convalsub = max([c1(cc) c2(cc)]); %take min contrast
            end
            maxcon = max([abs(100*c1(cc)) abs(100*c2(cc))]); %maximum contrast to determine overlay region
            conind  = find(fimcon>maxcon); %indices of overlapping region
            fim3(conind) = fim3(conind)-convalsub; %set point of overlap to equal one bar or the other
        end
    end

    fim3=ImClip(fim3,[pdim(2) pdim(1)]);
    fim3(fim3>1)=1;
    fim3(fim3<-1)=-1;
    if c1>c2 %corrects addition of two lines to make equal contrast at all points
        fim3(fim3>c1(cc))=c1(cc);
    else
        fim3(fim3>c2(cc))=c2(cc);
    end
    crosses(:,:,cc)=fim3; %store each cross
end
