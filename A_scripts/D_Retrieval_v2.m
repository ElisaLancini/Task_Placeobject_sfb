
%%%%%%%%%%%%%%%%%%%%% (D) Retrieval %%%%%%%%%%%%%%%%%%%%%%%%

%%% Information %%%

    % 60 stimuli
    % Condition A (ISI TYPE)
    % Condition B (Stimuli recall)

%%% Design %%%

    % Fixation cross    = ISI
    % Cue               = 4,5
    % Fixation cross    = ISI
    % BEKANNT/NEU       = 3
    % Fixation cross    = ISI
    % SICHER / UNSICHER = 3
    % Fixation cross    = ISI
    % Selection         = 5
    

    
    % Pauses         = 17/34 (every 17)

% To stop the script press 't' during selection phase.

clc
clearvars

%% 1. Set paths
path.root    = 'C:\Users\elisa\Dropbox\PhD\Experiments\B_Sfb_pilot\C_scripts\Version_2\';
path.task    = [ path.root 'A_scripts']; %Stimlist is here
path.sti     = 'C:\Users\elisa\Dropbox\PhD\Stimuli\Place_object\A_All_stimuli\';
path.emopics = 'C:\Users\elisa\Dropbox\PhD\Stimuli\EmoPicS\'; 
path.res     = [ path.root 'D_results\'];
path.input   = [ path.root 'B_inputfiles\'];
path.config  = [ path.root 'C_ISIfiles\'];
path.ptb   =  '/Users/elancini/Documents/MATLAB/Psychtoolbox/';% Path PTB
path.gstreamer= 'C:\gstreamer\1.0\x86_64\bin';
addpath(genpath(path.ptb));%% 2. Subject infos

%% 2. Subject infos

% Subject informations
input_prompt = {'Participant number'; 'Condition A'; 'Condition B'; 'YA(1)/ OA (2)?';'Session (1= prac.Enc / 2= enc / 3= prac.Retr / 4=retr)'};
input_defaults     = {'01','1', '1', '99','99'}; % Mostra input default per non guidare l'inserimento
input_answer = inputdlg(input_prompt, 'Informations', 1, input_defaults);
clear input_defaults input_prompt
%Modifiy class of variables
ID          = str2num(input_answer{1,1});
ConditionA  = str2num(input_answer{2,1}); % ISI randomization
ConditionB  = str2num(input_answer{3,1}); % stimuli to present from encoding
Group       = str2num(input_answer{4,1}); % Age group
Session     = str2num(input_answer{5,1}); % stimuli from previous task to be presented

% Check if is the experimenter is using the right script
if Session ~= 4
    errordlg('You are running the wrong script','Session error');
    return
end

% Check if Conditions are >1 and <2 , otherwise error will occur

if ConditionA > 2 || ConditionB > 2 || ConditionA == 0 || ConditionB == 0
    errordlg('Condition does not eist, check','Condition error');
    return
end

% Check if data already exist
cd(path.res)
if exist([num2str(ID) '_' num2str(Session) '_randinfo.mat']) == 2
    check_prompt = {'(1) Append a "r" / (2) Overwrite /(3) Break'};
    check_defaults     = {'1'}; % default input
    check_answer = inputdlg(check_prompt, 'No bueno', 1, check_defaults);
    check_decision= str2double(check_answer); % Depending on the decision..
    if check_decision == 1
        ID= [num2str(ID) '_R']; %append r to filename
    elseif check_decision == 3  %break
        return;
    end
end

%% 3. Load settings
cd(path.input)
Settings_retrieval;

%% 4. Pre allocate

response_key=zeros(numTrials,1);
response_key_question=zeros(numTrials,1);
response_time=zeros(numTrials,1);
response_time_question=zeros(numTrials,1);
response_kbNum=zeros(numTrials,1);
response_kbNum_question=zeros(numTrials,1);

idx=[]; %Index of cue
time_pause=zeros(1,70);
time_end=999;
events=cell(1,2);

%% 5. Load stimuli list from encoding session
%load stimuli_list_ordered in the encoding session
cd(path.res)
load([num2str(ID) '_2_' 'randinfo'],'rows_rand1');
load([num2str(ID) '_2_' 'randinfo'],'rows_rand2');
load([num2str(ID) '_2_' 'randinfo'],'stimuli_list');
stimuli_list_encoding=stimuli_list;
rows_rand1_encoding=num2cell(rows_rand1);
rows_rand2_encoding=num2cell(rows_rand2);

clear rows_ordered stimuli_list_ordered stimuli_list rows_rand1 rows_rand2
%% 5. Load list of new file
cd(path.input)
load('inputfile_new_60.mat');
inputfile_new=uploadedfile;
clear uploadedfile

%% Create matrix with old stimuli (60*2) and new 60 (only room empty, no selection)


% %% ---------- Create matrix of stimuli depending on ISI trialtype ------- %
% 
% %  Load ITI
% cd(path.config);
% 
% if ConditionA ==1
%     load('ISI_retr_1.mat');
% elseif ConditionA ==2
%     load('ISI_retr_2.mat');
% elseif exist(ConditionA,'var')== 0
%     check_conditionA = {'Please specify condition A'};
%     check_defaults     = {'1'}; % default input
%     check_answer = inputdlg(check_conditionA, 'No condition specified !', 1, check_defaults);
%     ConditionA= str2double(check_answer); % Depending on the decision..
%     if ConditionA ==1
%         load('ISI_retr_1.mat');
%     elseif ConditionA ==2
%         load('ISI_retr_2.mat');
%     end
% end
% 
% ISI= design_struct.eventlist(:, 4); %PTB uses seconds
% 

% % Create ISI per fixation cross
% fixation_duration(:,1)=ISI(1:2:100) ; %fixation cross 1
% fixation_duration(:,2)=ISI(2:2:100) ; %fixation cross 2

% -----------------TEMPORARY-----------------------------------------
% ----------  load ISI trialtype -------- %
% Load ITI
cd(path.config);

if ConditionA ==1
    load('ISI_enc_1.mat');
elseif ConditionA ==2
    load('ISI_enc_2.mat');
elseif exist(ConditionA,'var')== 0
    check_conditionA = {'Please specify condition A'};
    check_defaults     = {'1'}; % default input
    check_answer = inputdlg(check_conditionA, 'No condition specified !', 1, check_defaults);
    ConditionA= str2double(check_answer); % Depending on the decision..
    if ConditionA ==1
        load('ISI_enc_1.mat');
    elseif ConditionA ==2
        load('ISI_enc_2.mat');
    end
end

ISI= [design_struct.eventlist(:, 4);design_struct.eventlist(:, 4)]; %PTB uses seconds

% Create ISI per fixation cross
fixation_duration(:,1)=ISI(1:4:1200) ; %fixation cross 1
fixation_duration(:,2)=ISI(2:4:1200) ; %fixation cross 2
fixation_duration(:,3)=ISI(3:4:1200) ; %fixation cross 3 
fixation_duration(:,4)=ISI(4:4:1200) ; %fixation cross 3 

% ------------------end of temporsry variables----------------------------------------

% ---------- Randomize stimuli position on the screen ------- %

% Monitor
[windowPtr,rect]=Screen('OpenWindow',0,backgroundColor);
slack = Screen('GetFlipInterval', windowPtr)/2; %Calcola quanto tempo ci sta a flippare lo schermo (serve poi per il calcolo del tempo di present)
% rect=Screen('Rect', 0,0); %Comment this if you want to refer to small size monitor, let it code if you want to refer to full monitor
% Display variables
xMax=rect(1,3);
yMax=rect(1,4);
xCenter= xMax/2;
yCenter= yMax/2;
% Coordinates
topcentral=[xCenter-(picWidth/2), gap, xCenter+(picWidth/2), gap+picHeight];
pos_central= [ xCenter-(objpicWidth/2), gap+picHeight+gapHeight, xCenter+(objpicWidth/2), gap+picHeight+gapHeight+objpicHeight];
pos_left= [topcentral(1,1),  gap+picHeight+gapHeight, topcentral(1,1)+objpicWidth , gap+picHeight+gapHeight+objpicHeight];
pos_right= [topcentral(1,3)-objpicWidth,  gap+picHeight+gapHeight, topcentral(1,3) , gap+picHeight+gapHeight+objpicHeight];
% Randomize coordinates of choices on the screen
stimuli_choice_pos= cell(1,3);
where={pos_left,pos_central, pos_right};
for x=1:(numTrials)
    stimuli_choice_pos(x,:)=Shuffle(where);
end

clear x

%% 7. Save randomization information
 save([path.res num2str(ID) '_' num2str(Session) '_randinfo.mat']);
%% TASK
% try
    %% ------ Welcome screen ------ %
    Screen('TextSize', windowPtr,50);               %Set text size
    Screen('TextFont', windowPtr,'Helvetica');      %Set font
    Screen('TextStyle', windowPtr,0);               %Set style
    line1='Willkommen zum Experiment';              %Set text, location (xy)and color
    line2='\n';
    line3='\n\n Drucken Sie die Leertaste, um zu starten';
    DrawFormattedText(windowPtr,[line1 line2 line3], 'center','center', textColor);    %Show the results on the screen
    Screen('Flip', windowPtr);
    %Wait untile spacebar is pressed
    while 1
        [keyIsDown,secs,keyCode] = KbCheck;
        if keyCode(KbName('SPACE'))==1
            break
        end
    end
    
    t_last_onset(1)=secs;

    %% ------ Stimuli presentation ------ %
        
    startscript=tic; %start couting the time for completing the entire task
    
    for i = 1:numTrials
        % ---------- Fixation cross ---------- %
        crossLines= [-crossLenght, 0 ; crossLenght, 0; 0 , -crossLenght; 0, crossLenght];
        crossLines= crossLines';
        Screen('DrawLines', windowPtr, crossLines, crossWidth, crossColor, [xCenter, yCenter]);
        t_fixation_onset1(i)=Screen('Flip',windowPtr,  t_last_onset(i)-slack);
        t_fixation_offset1(i)=Screen('Flip',windowPtr,t_fixation_onset1(i)+fixation_duration(i,1)-slack);        
        % ---------------- Cue ---------------- %
        pic_cue=imread([path.sti stimuli_list{1, 2}{i, 1}], 'png');
        pic_cue_texture=Screen('MakeTexture', windowPtr, pic_cue);
        Screen('DrawTexture', windowPtr, pic_cue_texture, [], topcentral);
        t_cue_onset(i)= Screen('Flip', windowPtr, t_fixation_offset1(i)-slack); % show image
        t_cue_offset(i)=Screen('Flip', windowPtr, t_cue_onset(i)+ cue_duration-slack); % show image
    % ---------- Fixation cross 2 ---------- %
    crossLines= [-crossLenght, 0 ; crossLenght, 0; 0 , -crossLenght; 0, crossLenght];
    crossLines= crossLines';
    Screen('DrawLines', windowPtr, crossLines, crossWidth, crossColor, [xCenter, yCenter]);
    t_fixation_onset2(i)=Screen('Flip',windowPtr, t_cue_offset(i)-slack);
    t_fixation_offset2(i)=Screen('Flip',windowPtr,t_fixation_onset2(i)+fixation_duration(i,2)-slack);
    % ---------------- Selection ---------------- %
        % Select which picture to read
        pic_alt1=imread([path.sti stimuli_list{1, 3}{i, 1}], 'jpg'); % object
        pic_alt2=imread([path.sti stimuli_list{1, 4}{i, 1}], 'jpg'); % internal lure
        pic_lure=imread([path.sti stimuli_list{1, 5}{i, 1}], 'jpg'); % external lure
        %Make textures of them
        pic_alt1_texture=Screen('MakeTexture', windowPtr, pic_alt1);
        pic_alt2_texture=Screen('MakeTexture', windowPtr, pic_alt2);
        pic_lure_texture=Screen('MakeTexture', windowPtr, pic_lure);
        % Put them toghtether (....if you want to present them in the same screen)
        pics=[pic_cue_texture pic_alt1_texture pic_alt2_texture pic_lure_texture]';
        % Concatenate position of the pics
        positions=[topcentral' , stimuli_choice_pos{i, 1}' , stimuli_choice_pos{i, 2}' , stimuli_choice_pos{i, 3}'];
        % Flip (draw all toghether)
        Screen('DrawTextures', windowPtr, pics, [], positions);
        t_selection_onset(i)= Screen('Flip', windowPtr,  t_fixation_offset2(i)-slack);        
        %Record response
        FlushEvents('keyDown')
        t1 = GetSecs;
        time = 0;
        while time < selection_timeout
            [keyIsDown,t2,keyCode] = KbCheck; %determine state of keyboard
            time = t2-t1 ;
            if (keyIsDown) %has a key been pressed?
                key = KbName(find(keyCode));
                type= class(key);
                if type == 'cell' %If two keys pressed simultaneously, then 0
                    response_key(i,1)= 99;
                    response_kbNum(i,1)= 99;
                    response_time(i,1)= 99;
                elseif key== 'a'
                    response_key(i,1)= 1; %if a was pressed, 1
                    response_time(i,1) =time;
                    response_kbNum(i,1)= find(keyCode);
                elseif key == 'space'
                    response_key(i,1)= 2; %if space was pressed, 2
                    response_time(i,1) =time;
                    response_kbNum(i,1)= find(keyCode);
                elseif key == 'l'
                    response_key(i,1) =3; %if l was pressed, 2
                    response_time(i,1) =time;
                    response_kbNum(i,1)= find(keyCode);
                elseif key == 't'
                    events{1, 1}= 'Script aborted' ;
                    events{1, 2}= i ;
                    events{1, 3}= toc(startscript) ;
                    sca %A red error line in the command window will occur:  "Error using Screen".
                end
            end
        end
        t_selection_offset(i)= Screen('Flip', windowPtr, t_selection_onset(i)+selection_timeout-slack);
        time_lastbackup=toc(startscript);
        t_last_onset(i+1)=t_selection_offset(i); 

        % Backup of answers after every keypressed
         save([path.res num2str(ID) '_' num2str(Session) '_backup.mat']);        
        
        % ------------- ???? Pause ??? -------------%
        %After half of the trials, pause.
        if i == breakAfterTrials1 || i==breakAfterTrials2 || i==breakAfterTrials3
            Screen('TextSize', windowPtr,50);               %Set text size
            Screen('TextFont', windowPtr,'Helvetica');      %Set font
            Screen('TextStyle', windowPtr,0);               %Set style
            if i == breakAfterTrials1 || i == breakAfterTrials2 || i == breakAfterTrials3 || i == breakAfterTrials4 || i == breakAfterTrials5 || i == breakAfterTrials6
                line1='Sie konnen eine Pause machen';              %Set text, location (xy)and color
            elseif i== breakAfterHalfTrials
                line1='Die Halfte des Experiments ist abgeschlossen.';              %Set text, location (xy)and color
            end
            line2='\n';
            line3='\n\n Drucken Sie die Leertaste, um zu starten';
            DrawFormattedText(windowPtr,[line1 line2 line3], 'center','center', textColor);    %Show the results on the screen
            t_pause_onset(i)= Screen('Flip', windowPtr); % show image
            startpause=tic; % start counting the seconds of pause
            %Wait untile spacebar is pressed
            while 1
                [keyIsDown,secs,keyCode] = KbCheck;
                if keyCode(KbName('SPACE'))==1
                    break
                end
            end
            time_pause(i)=toc(startpause); % how many seconds of pause did the participant take?
            clear tic % so it doesn't interfere with the main tic
            t_pause_offset(i)=t_pause_onset(i)+secs-slack; %variable that in the loop becames the feedback timestamp
        end   
    end
    
    time_end=toc(startscript); %calculate time for completing entire task
    
    
    %%  -------- End screen -------- %
    Screen('TextSize', windowPtr,50); %Set text size
    Screen('TextFont', windowPtr,'Helvetica'); %Set font
    Screen('TextStyle', windowPtr,0); %Set style
    line1='Das Experiment ist beendet';
    line2='\n';
    line3='\n\n Vielen Dank fur Ihre Teilnahme';
    DrawFormattedText(windowPtr,[line1 line2 line3], 'center','center', textColor);
    t_end_onset=Screen('Flip', windowPtr);     %Show the results on the screen
    t_end_offset=Screen('Flip', windowPtr,t_end_onset(end)+5-slack);     %Show the results on the screen
    sca %Close all
    
    %% 8. Re enable keyboard
    RestrictKeysForKbCheck;
    ListenChar(0);
    
    %% 9. Save before analysis
    
     save([path.res num2str(ID) '_' num2str(Session) '_raw.mat']);

%% 10. Analyze answers

% Find pictures real position
% cue, alternative, external lure
% 1=left, 2=center, 3= right
stimuli_choice_pos_coded=[1,1];
for c=1:3
    for r = 1:(numTrials)
        position=stimuli_choice_pos{r,c};
        if position(1) == pos_left(1,1)
            stimuli_choice_pos_coded(r,c)= 1;
        elseif position(1) == pos_central(1,1)
            stimuli_choice_pos_coded(r,c)= 2;
        elseif position(1) ==  pos_right(1,1)
            stimuli_choice_pos_coded(r,c)= 3;
        end
    end
end

% Find correct answers and errors
answers=[];
for r=1:length(response_key)
    if ismember(response_key(r),stimuli_choice_pos_coded(r,1)) == 1 %cue column
        answers(r,1)= 1; %Correct answers
    elseif ismember(response_key(r),stimuli_choice_pos_coded(r,2)) == 1 %internal lure colums
        answers(r,1)= 2; %Internal lure
    elseif ismember(response_key(r),stimuli_choice_pos_coded(r,3)) == 1 %external lure column
        answers(r,1)= 3; %External lure
    elseif response_key(r) == 0
        answers(r,1)= 0; %no response was made
    elseif response_key(r) == 99
        answers(r,1)= 99; % multiple response were made
    end
end

%% 11. Resume

% Total results
results.hints=sum(answers==1);
results.falseallarm=sum(answers==2);
results.errors=sum(answers==3);
results.missed=sum(answers==0);
results.multiple=sum(answers==99);
results.totalresponse=sum(results.hints+results.falseallarm+results.errors); % might not work....

% Trial related results (negative emopic follows(1) /neutral emopic follows (0))
for i = 1:numTrials
    
    if stimuli_list{1, 6}{i, 1} == 1
        negative_emopic_answers(i,1)= answers(i,1)   ;
        neutral_emopic_answers(i,1) = 0   ; %if it is not
    else
        neutral_emopic_answers(i,1) = answers(i,1)   ;
        negative_emopic_answers(i,1)= 1    ;
    end
end

% Total results
results.hints_1=sum(negative_emopic_answers==1);
results.falseallarm_1=sum(negative_emopic_answers==2);
results.errors_1=sum(negative_emopic_answers==3);
results.missed_1=sum(negative_emopic_answers==0);
results.multiple_1=sum(negative_emopic_answers==99);
results.totalresponse_1=sum(results.hints_1+results.falseallarm_1+results.errors_1); %might not work.....

results.hints_0=sum( neutral_emopic_answers==1);
results.falseallarm_0=sum( neutral_emopic_answers==2);
results.errors_0=sum( neutral_emopic_answers==3);
results.missed_0=sum( neutral_emopic_answers==0);
results.multiple_0=sum( neutral_emopic_answers==99);
results.totalresponse_0=sum(results.hints_0+results.falseallarm_0+results.errors_0); %might not work....

%% 12. Save
stimuli.stimuli_randomized= stimuli_list;
stimuli.row_randomization= rows_rand;
stimuli.labels={'EncImg3','Cue','Right Alternative','Wrong Alternative2','ExtLure','TrialType(Neutral=0/Negative=1)','CueType','EmoPic'};
stimuli.emopics_negative_row_randomization=rows_rand_emopics_negative;
stimuli.emopics_neutral_row_randomization=rows_rand_emopics_neutral;
stimuli.choice_position = stimuli_choice_pos;
stimuli.choice_position_coded = stimuli_choice_pos_coded;

answer.response_kbNum=response_kbNum;
answer.response_key  =response_key;
answer.response_time =response_time;
answer.all_answers   = answers;
answer.negative_pic_answers = negative_emopic_answers;
answer.neutral_pic_answers = neutral_emopic_answers;

timing.end=(time_end/60); %from seconds to minutes (are now in msec because calculated by Matlab)
timing.pause=time_pause/60;
timing.last_backup=time_lastbackup/60;
timing.fixation_onset1=t_fixation_onset1; % fixation crosses (n=2)
timing.fixation_offset1=t_fixation_offset1;
timing.fixation_onset2=t_fixation_onset2; 
timing.fixation_offset2=t_fixation_offset2;
timing.ISI_fixation_duration=fixation_duration;
timing.room_onset=t_room_onset; % room
timing.room_offset=t_room_offset;
timing.selection_onset=t_selection_onset; % selection
timing.selection_offset=t_selection_offset;
timing.feedback_onset=t_feedback_onset; % feedback
timing.feedback_offset=t_feedback_offset;
timing.emopic_onset=t_feedback_onset; % emoPics
timing.feedback_offset=t_feedback_offset;
timing.end_onset=t_end_onset; %end screen
timing.end_offset=t_end_offset;
timing.slack=slack; % slack (difference between screen flip and VBL)


participant_info.ID=ID;
participant_info.age_group=Group;
participant_info.group_ISI=ConditionA;
participant_info.stimuli_from_encoding=ConditionB;



%% 13. Save results
save([path.res num2str(ID) '_' num2str(Session) '.mat']...
    , 'participant_info' ...
    , 'stimuli' ...
    , 'results' ...
    , 'answer' ...
    , 'timing' );


