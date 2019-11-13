% ThisDirectory
function CallingDir=ThisDirectory()
Callers=dbstack('-completenames') ;
if length(Callers)>1
    CallingName=which(Callers(2).name);
    CallingDir=CallingName(1:end-(2+length(Callers(2).name)));
else
    CallingDir='';
end