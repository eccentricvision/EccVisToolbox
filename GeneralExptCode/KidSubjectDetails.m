function [subject] = KidSubjectDetails(Directory,Initials,Group)
%[subject] = KidsSubjectDetails(Directory,Initials)
%function to check whether subject details have been entered
%or to enter them in and save a file if they don't exist
%both Directory and Initials should be input as strings
%returns a structure called 'subject'
%
%v2.0 - updated to remove handedness and dominant eye questions as default - unnecessary and time-consuming to ask if not needed
%J Greenwood August 2018

DaysInMonth = mean([31 28 31 30 31 30 31 31 30 31 30 31]); %for conversion of ages into months
monthlab    = {'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'};

if exist(strcat(Directory,Initials,'-details.mat'),'file'); %then we've used this subject before
    load(strcat(Directory,Initials,'-details.mat')); %load the file, which returns the structure 'subject'
else %get the inputs and save the file, return 'subject' as well
    subject.Init   = Initials;%initials
    subject.Date   = datestr(now,'yyyy-mm-dd'); %day when the file was generated
    subject.Time   = datestr(now,'HH:MM:SS'); %time when the file was generated
    
    daybirth   = DefInput('Day of birth (1-31)',01);
    monthbirth = DefInput('Month of birth (1-12)',12);
    yearbirth  = DefInput('Year of birth (XXXX)',1900);
    
    subject.DOB       = strcat(num2str(daybirth),'-',monthlab{monthbirth},'-',num2str(yearbirth));%DefInput('Date of birth (use 20-dec-2004 format)','99-mon-9999');
    subject.AgeYears  = daysact(subject.DOB,subject.Date)/365; %age in years
    subject.AgeMonths = daysact(subject.DOB,subject.Date)./DaysInMonth; %age in months
    
    subject.Gender = DefInput('Gender? 0=Male, 1=Female',1); %gender
    if subject.Gender==0
        subject.GenderLabel = 'male  ';
    else %to put an else here is a little cis-gender I guess but we can change this should a transgender person ever arrive
        subject.GenderLabel = 'female';
    end
    
%     subject.Hand   = DefInput('Handedness? 0=Left, 1=Right',1); %handedness
%     if subject.Hand==0
%         subject.HandLabel = 'left '; %store a string just to be sure there's no ambiguity
%     else
%         subject.HandLabel = 'right';
%     end
    
    if Group==0 %control kid
%         subject.DomEye = DefInput('Dominant Eye? 0=Left, 1=Right',0); %dominant sighting eye
%         if subject.DomEye==0
%             subject.DomEyeLabel = 'left ';%store a string just to be sure there's no ambiguity
%         else
%             subject.DomEyeLabel = 'right';
%         end
    elseif Group==1 %child with amblyopia
        subject.AmbEye   = DefInput('Amblyopic Eye? 0=Left, 1=Right',0); %which eye has amblyopia
        subject.AmbType  = DefInput('Amblyopia type? 1=Strab, 2=Aniso, 3=Both, 4=Other',1);
        switch subject.AmbType
            case 1
                subject.AmbLabel = 'Strabismus';
            case 2
                subject.AmbLabel = 'Anisometropia';
            case 3
                subject.AmbLabel = 'Mixed Strab/Aniso';
            case 4
                subject.AmbLabel = 'Other';
        end
        subject.TestSession = 1; %test session is 1 if this is the first time the code is being run (denotes how many times this child has been seen before)
    elseif Group==2 %CRB1 kids
        subject.GroupLabel = 'CRB1';
        subject.logMARval  = DefInput('Enter orthoptic logMAR acuity',0);
    end
    
    disp('  '); %some space to separate the input options a little
    
    fName=strcat(Directory,Initials,'-details.mat');
    save(fName,'subject'); %save 'subject' structure into .mat file to be re-loaded later
end

