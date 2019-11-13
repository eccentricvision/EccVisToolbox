function c = PythagoraSolveC(a,b)
%function to get the diagonal value of a right-angle triangle
%Pythagora's theorem of c2 = a2 + b2
%returns c as in sqrt(a^2 + b^2)
%J Greenwood Oct 2014
%e.g. c = PythagoraSolveC(40,30); disp(c);

c = sqrt((a.^2)+(b.^2)); %pythagora's theorem to get c