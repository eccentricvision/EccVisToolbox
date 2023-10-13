function [subject] = SubjectDetails(Directory,Initials)
%[subject] = SubjectDetails(Directory,Initials)
%function to check whether subject details have been entered
%or to enter them in and save a file if they don't exist
%both Directory and Initials should be input as strings
%returns a structure called 'subject'
%
%J Greenwood October 2014

if exist(strcat(Directory,Initials,'-details.mat'),'file'); %then we've used this subject before
    load(strcat(Directory,Initials,'-details.mat')); %load the file, which returns the structure 'subject'
else %get the inputs and save the file, return 'subject' as well
    subject.Init   = Initials;%initials
    subject.Age    = DefInput('Subject Age (Yrs)?',99); %age
    
    subject.Gender = DefInput('Gender? 0=Male, 1=Female, 2=Other',1); %gender
    if subject.Gender==0
        subject.GenderLabel = 'male  ';
    elseif subject.Gender==1
        subject.GenderLabel = 'female';
    else 
        subject.GenderLabel = 'other ';
    end
    
    subject.Hand   = DefInput('Handedness? 0=Left, 1=Right',1); %handedness
    if subject.Hand==0
        subject.HandLabel = 'left '; %store a string just to be sure there's no ambiguity
    else
        subject.HandLabel = 'right';
    end
    
    subject.DomEye = DefInput('Dominant Eye? 0=Left, 1=Right',0); %dominant sighting eye
    if subject.DomEye==0
        subject.DomEyeLabel = 'left ';%store a string just to be sure there's no ambiguity
    else
        subject.DomEyeLabel = 'right';
    end
    
    subject.Date   = datestr(now,'yyyy.mm.dd'); %day when the file was generated
    subject.Time   = datestr(now,'HH:MM:SS'); %time when the file was generated
    disp('  '); %some space to separate the input options a little
    
    fName=strcat(Directory,Initials,'-details.mat');
    save(fName,'subject'); %save 'subject' structure into .mat file to be re-loaded later
end

