function [xVal,yVal,AnnuliRad,NumCircFinal]=AnnulusArrayPositions(px,py,inRad,outRad,NumAnnuli,CircRad,Spacing,SamePhase)
%[xVal,yVal,AnnuliRad,NumCircFinal]=AnnulusArrayPositions(px,py,inRad,outRad,NumAnnuli,CircRad,Spacing,SamePhase)
%function to get an array of x,y positions for circles positioned on an array of annuli
%
%px/py = patch dimensions, inRad,outRad = inner and outer radius for annuli,
%NumAnnuli = how many rings of circles, CircRad = radius of individual circles,
%spacing = circumferential gap between circles, SamePhase = 0/1 determines
%whether all elements begin at the same phase of the annulus (0) or alternate depending on the angular separation between elements
%
%for an annulus of circles the maximum number of circles within is set by
%the size of circles and the annulus radius, such that where a and b are
%the inner and outer edges of the circles, the angle between them will be
%? = 2*arcsin[(a-b)/(a+b)] in radians.
% The number of inscribed circles is thus N = 2?/? (if theta in radians)
% from http://www.had2know.com/academics/circles-inscribed-annulus-calculator.html
%
%e.g. [xVal,yVal]=AnnulusArrayPositions(200,300,0,200,15,10,2,1);plot(xVal,yVal,'o-');axis square
%eg2. [xVal,yVal]=AnnulusArrayPositions(200,300,0,200,12,10,2,0);plot(xVal,yVal,'o','MarkerSize',20);axis square;
%eg3. [xVal,yVal,AnnuliRad,NumCirc]=AnnulusArrayPositions(400,400,50,100,5,10,0,0);plot(xVal,yVal,'o','MarkerSize',20);axis square;
%J Greenwood 2015

if ~exist('SamePhase')
    SamePhase = 1;
end

AnnuliRad = round(linspace(inRad,outRad,NumAnnuli));%round(linspace(0,max([halfpx-CircRad halfpy-CircRad]),NumAnnuli));
for aa=1:NumAnnuli
    Circum(aa)        = round(2*pi*AnnuliRad(aa));
    %CircumSpacing(aa) = (Circum(aa))./((CircRad*2)+Spacing);
    InnerRad(aa) = (AnnuliRad(aa)-(CircRad+(Spacing/2)));
    OuterRad(aa) = (AnnuliRad(aa)+(CircRad+(Spacing/2)));
    CircSepTheta(aa)  = 2*(asin((OuterRad(aa)-InnerRad(aa))./(OuterRad(aa)+InnerRad(aa))));%in radians
    %? = 2*arcsin[(a-b)/(a+b)].
end
CircSepTheta = real(CircSepTheta); %remove any imaginary components
NumCirc      = round((2*pi)./CircSepTheta); %floor((2*pi)./CircSepTheta);
xVal = [];
yVal = [];
PhaseVal(1) = 0;
for aa=1:NumAnnuli
    if AnnuliRad(aa)==0 %centre circle
        xAnn{aa} = 0;
        yAnn{aa} = 0;
    else %plot a circle
        if SamePhase
            PhaseVal(aa) = 0;
        else
            if mod(aa,2) %1=odd 0=even
                PhaseVal(aa) = 0; %odd annuli = 0 phase
            else
                PhaseVal(aa) = CircSepTheta(aa)/2; %half the angular offset = phase offset for even annuli
            end
        end
        CircPlotTheta{aa}  = linspace(0+PhaseVal(aa),(pi)+PhaseVal(aa),(NumCirc(aa)/2));
        CircPlotTheta{aa} = CircPlotTheta{aa}(1:end-1);
        CircPlotTheta{aa} = horzcat(CircPlotTheta{aa},CircPlotTheta{aa}+pi);
        %CircPlotTheta{aa} = CircPlotTheta{aa}(1:end-1);
        %CircPlotTheta{aa} = 0:CircSepTheta(aa):pi;%-(CircSepTheta(aa)+PhaseVal(aa));%linspace(0+PhaseVal(aa),(pi-(CircSepTheta(aa)+PhaseVal(aa))),NumCirc(aa)); %-(CircSepTheta(aa)
        %CircPlotTheta{aa} = horzcat(CircPlotTheta{aa},CircPlotTheta{aa}+pi);
        %CircPlotTheta{aa} = CircPlotTheta{aa};
        %CircPlotTheta{aa} = CircPlotTheta{aa}(1:end-1);
        %CircPlotTheta{aa} = 0:CircSepTheta(aa):(2*pi);%linspace(0,2*pi,NumCirc(aa));
        %AdjustVal = ((2*pi)-CircPlotTheta{aa}(end))/2 %value to shift angles by to keep symmetry around the origin theta
        %CircPlotTheta{aa} = CircPlotTheta{aa}+AdjustVal;
        [xAnn{aa},yAnn{aa}] = pol2cart(CircPlotTheta{aa},ones(1,numel(CircPlotTheta{aa})).*AnnuliRad(aa));
    end
    xVal = horzcat(xVal,xAnn{aa});
    yVal = horzcat(yVal,yAnn{aa});
    NumCircFinal(aa) = numel(xAnn{aa}); %how many circles actually drawn in each annulus
end

