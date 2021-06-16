%% Import the data and process
clear;clc;

%%data_path = 'C:\Users\pldem\Desktop\Behavioral Raw Data';       %Alter for your computer
data_path = 'C:\Users\fbone\Documents\RayLab\RawData_MagNegPunish';
all_files = dir(data_path); 
m = '\![0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}h[0-9]{2}m.Subject PD#[0-9]'; 
n = '\![0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}h[0-9]{2}m.Subject NSC29' ;

%Set up arrays for saving accuracy data
setDays = 23;
totals = zeros(setDays, 5);
rightTotals = zeros(setDays, 5);
leftTotals = zeros(setDays, 5);

%Parse files for ones with specific names
files = {}; 
for ii = 1:length(all_files)    
    if  regexp(all_files(ii).name,n)   
        files = [files fullfile(all_files(ii).folder, all_files(ii).name)];
    end
    if  regexp(all_files(ii).name,m)   
        files = [files fullfile(all_files(ii).folder, all_files(ii).name)];
    end
end

    day13 = 0;
    day14 = 0;
    d22n1 = false;
    d22n5 = false;
    
%Go through each file
for ii = 1:length(files)
    curr = files{ii};
    info.date = behv_ExtractTextData(curr,'Start Date');        
    info.subj = behv_ExtractTextData(curr,'Subject');
    info.exp = behv_ExtractTextData(curr,'Experiment');
    info.grp = behv_ExtractTextData(curr,'Group');
    info.box = behv_ExtractTextData(curr,'Box');
    info.starttime = behv_ExtractTextData(curr,'Start Time');
    info.endtime = behv_ExtractTextData(curr,'End Time');
    info.msn = behv_ExtractTextData(curr,'MSN');
    C = behv_ExtractNumericalData(curr,'C');
    E = behv_ExtractNumericalData(curr,'E');
    F = behv_ExtractNumericalData(curr,'F');
    
    % skip if length of E is < 100
    if length(E) < 100
        continue;
    end
    
    % truncate E
    truncate_flag = false;              %Cuts off the end zeros if the data is larger than 100 indecies 
    for jj = 1:length(E)
        if E(jj) == 0 && E(jj+1) == 0 && E(jj+2) == 0
            truncate_flag = true;
            break;
        end
    end
    if truncate_flag
        E(jj:end) = [];
    end
    
    events = E(2:3:end);    
    timestamps = E(3:3:end);
    
    eid = phillip_getEventTypes();
    
    % next step -- make a function to print out the time stamps with event
    % descriptions so we can look for patterns
    
    eventTime = zeros(length(events), 2);
    for i = 1:length(events)
        eventTime(i, 1) = timestamps(i);
        eventTime(i, 2) = events(i); 
    end
    
    % parse trial data
    % find all trial beginning indexes
    trial_beginnings_idx = find(events == eid.Event_Trial_Begins)';     
    trial_endings_idx = find(events == eid.Event_Trial_Ends)';
    
    if length(trial_beginnings_idx) > length(trial_endings_idx)         
        trial_beginnings_idx = trial_beginnings_idx(1:end-1);
    end
    
    nTrials = length(trial_beginnings_idx);     %Number of trials marked
    
    % columns
    %   1. trial beginning time
    %   2. trial ending time
    %   3. low tone (-1) or high tone (1)
    %   4. left magazine poke (-1) or right magazine poke (1)
    %   5. pellet rewarded (1) or not rewarded (0)
    TRIALS = zeros(nTrials,7);
    
    successCount = 0;
    rightSuccessCount = 0;
    leftSuccessCount = 0;
    leftCount = 0;
    rightCount = 0;
    
    % Get subject number and day number
    if strcmp(info.subj, 'PD#2`')
        subjectNum = 2;
    else
        subjectNum = str2num(info.subj(end));
    end
    if str2num(info.grp(end - 1))
         dayNum = str2num(info.grp(end)) + str2num(info.grp(end-1))*10;
    else 
        dayNum = str2num(info.grp(end));
    end
    if dayNum > 8 && dayNum < 15
        dayNum = dayNum - 1;
    end
    if dayNum == 12 && day13 == 5
        dayNum = 14;
    end
    if dayNum == 13 && day14 == 5
        dayNum = 15;
    end
    if dayNum == 12 
        day13 = day13 + 1;
    end
    if dayNum == 13
        day14 = day14 + 1;
    end
    if dayNum == 15
        dayNum = 16;
    end
    if subjectNum == 9
        subjectNum = 5;
    end
    if subjectNum == 1 && dayNum == 22
        d22n1 = true;
    end
    if subjectNum == 5 && dayNum == 22
        d22n5 = true;
    end
    if d22n1 || d22n5 
        dayNum = 23;
    end
   
   
    
    TRIALS(1, 6) = subjectNum;
    TRIALS(1, 7) = dayNum;
    
    for jj = 1:nTrials
        trial_start_time = timestamps(trial_beginnings_idx(jj)); %Find the timestamp for the begining and end of the trial
        trial_end_time = timestamps(trial_endings_idx(jj));
        
        tone = -999;
        tone_time = -999;
        poke = -999;
        poke_time = -999;
        reinforcement = -999;
        reinforcement_time = -999;
        
        % low tone or high tone?
        for kk = trial_beginnings_idx(jj):trial_endings_idx(jj)
            if events(kk) == eid.Event_LeftMag_LowTone      %If any events were the low tone, then the tone variable is -1
                tone = -1;  
                leftCount = leftCount + 1;
                tone_time = timestamps(kk);     %Mark the variable tone time 
                break;
            elseif events(kk) == eid.Event_RightMag_HighTone    %If any events were the high tone, then the tone variable is 1
                tone = 1;
                rightCount = rightCount + 1;
                tone_time = timestamps(kk);     %Mark variable tone time
                break;
            end
        end
        
        % left magazine poke or right magazine poke?
        for kk = trial_beginnings_idx(jj):trial_endings_idx(jj)
            if events(kk) == eid.Event_LeftMag_Poke
                poke = -1;
                poke_time = timestamps(kk);
                break;
            elseif events(kk) == eid.Event_RightMag_Poke
                poke = 1;
                poke_time = timestamps(kk);
                break;
            end
        end
        
        % pellet rewarded or not rewarded?
        for kk = trial_beginnings_idx(jj):trial_endings_idx(jj)
            if events(kk) == eid.Event_Reinforcement
                reinforcement = 1;
                successCount = successCount + 1;
                
                reinforcement_time = timestamps(kk);
                break;
            elseif events(kk) == eid.Event_NoReinforcement
                reinforcement = 0;
                reinforcement_time = timestamps(kk);
                break;
            end
        end
        
        if tone == -1 && poke == -1
            leftSuccessCount = leftSuccessCount + 1;
        end
        if tone == 1 && poke == 1
            rightSuccessCount = rightSuccessCount + 1;
        end
        
        TRIALS(jj,1:5) = [trial_start_time, trial_end_time, tone, poke, reinforcement];       %Start time, end time, tone type, poke side, if reinforcement
       
%         if jj == idivide(nTrials, int16(2))
%             index = (dayNum*2)-1;
%             leftAccuracy = leftSuccessCount/leftCount;
%             rightAccuracy = rightSuccessCount/rightCount;
%             totalAccuracy = successCount/(nTrials/2);
%     
%             totals(index, subjectNum) = totalAccuracy;
%             rightTotals(index, subjectNum) = rightAccuracy;
%             leftTotals(index, subjectNum) = leftAccuracy; 
%         end
            
    end
    
    %Find accuracy and place in arrays
    leftAccuracy = leftSuccessCount/leftCount;
    rightAccuracy = rightSuccessCount/rightCount;
    totalAccuracy = successCount/nTrials;
    
    totals(dayNum, subjectNum) = totalAccuracy;
    rightTotals(dayNum, subjectNum) = rightAccuracy;
    leftTotals(dayNum, subjectNum) = leftAccuracy; 
   
    T = array2table(TRIALS);
    T.Properties.VariableNames(1:7) = {'trial_start_time','trial_end_time','tone (LOW=-1, HIGH=+1)', 'poke (LEFT=-1, RIGHT=+1)', 'reinforcement(yes=1, no=0)', 'Subject identifier', 'Day number'};
    
    outputfolder = 'C:\Users\fbone\Documents\RayLab\ProcessedData_MagNegPunish';     %Alter for your computer 
    outputxlsx = [replace(curr,[data_path '\!'],''), '.xlsx'];
    outputmat = [replace(curr,[data_path '\!'],''), '.mat'];
    outputxlsxfile = fullfile(outputfolder,outputxlsx);
    outputmatfile = fullfile(outputfolder,outputmat);
    writetable(T,outputxlsxfile);
    save(outputmatfile,'TRIALS');
    
end
