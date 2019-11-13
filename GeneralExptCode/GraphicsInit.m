%Graphics initialisation
%GraphicsInit
%general code to initialise the experimental monitor and grab its
%properties, then draw a blank screen

AssertOpenGL;
screens=Screen('Screens');
if blackout  %black out main monitor
    [w2 screenRect2]=Screen('OpenWindow',min(screens),0,[],32,2); %get reference and resolution for main monitor
    blackim=zeros(screenRect2(3),screenRect2(4));
    Screen('FillRect',w2, [0 0 0]);
    Screen('Flip', w2);
end
%now draw to experimental monitor
[w screenRect]=Screen('OpenWindow',max(screens), 0,[],32,2); %max(Screens)
centX=screenRect(3)/2; centY=screenRect(4)/2;

if BitsYN
    bitsPlusRect = [0     0   524     1];               % The window we  write the Bits++ CLUT into
    newClutRow = BitsPlusEncodeClutRow((2^16-1).*hsv(256));  % Encode CLUT  ('hsv') using PTB routine
    clutText =Screen('MakeTexture', w, newClutRow);          % Make the  CLUT texture
    Screen('DrawTexture', w, clutText, [], bitsPlusRect,0,0);
    vbl=Screen('Flip', w);
end
