
%%%%%%%%%%%%%%%%%%%%% (D) Retrieval Rooms %%%%%%%%%%%%%%%%%%%%%%%%

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
    
% pauses: 20 / 40 / 60 / 80 / 100 / 120 (every 20 + half)

  
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

response_key_question=zeros(numTrials,1);
response_time_question=zeros(numTrials,1);
response_kbNum_question=zeros(numTrials,1);

idx=[]; %Index of cue
time_pause=zeros(1,70);
time_end=999;
events=cell(1,2);
%% 5. Load stimuli list (inputfile)

cd(path.input)
load('inputfile_retrieval_rooms.mat');
inputfile=uploadedfile;
clear uploadedfile

%% 6. Randomization

% 2.1 Randomize rows 
rows=(1:numTrials); % create vector with all row numbers in order (from 1 to 120)
rows_rand=rows(randperm(length(rows)))'; % Randomize the order of the numbers in this vector

clear rows1 rows2

% 2.2 Re-order stimuli

% 2.2 Re-order every row depending on the new row list and randomize cue
for n=1:numTrials %
    x= rows_rand(n);
    %Randomize columns 
    stimuli_list{1, 1}{x, 1} = inputfile{1, 1}{n, 1};  %room pic
    stimuli_list{1, 2}{x, 1} = inputfile{1, 9}(n, 1);  % new/old index
end

clear n x

% Create table
 
 for i=1:numTrials
 new_position_inputfiles{i, 1}=inputfile{1, 1}{i, 1};
 new_position_inputfiles{i, 2}=rows_rand(i,1);
 new_position_inputfiles{i, 3}=stimuli_list{1, 1}{i, 1};
 new_position_inputfiles{i, 4}=stimuli_list{1, 2}{i, 1};
 end
 
header={'Inputfile_name', 'new_position','file_name_in_new_position','old_or_new'};
new_position_inputfiles_table=cell2table(new_position_inputfiles,'VariableNames',header);
clear header 

% -----------------TEMPORARY-----------------------------------------
%% ----------  load ISI trialtype -------- %
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
% stimuli_choice_pos= cell(1,3);
% where={pos_left,pos_central, pos_right};
% for x=1:(numTrials)
%     stimuli_choice_pos(x,:)=Shuffle(where);
% end

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
        % ---------- Fixation cross 1 ---------- %
        crossLines= [-crossLenght, 0 ; crossLenght, 0; 0 , -crossLenght; 0, crossLenght];
        crossLines= crossLines';
        Screen('DrawLines', windowPtr, crossLines, crossWidth, crossColor, [xCenter, yCenter]);
        t_fixation_onset1(i)=Screen('Flip',windowPtr,  t_last_onset(i)-slack);
        t_fixation_offset1(i)=Screen('Flip',windowPtr,t_fixation_onset1(i)+fixation_duration(i,1)-slack);
        % ---------------- Room ---------------- %
        pic_room=imread([path.sti stimuli_list{1, 1}{i, 1}], 'jpg');
        pic_room_texture=Screen('MakeTexture', windowPtr, pic_room);
        Screen('DrawTexture', windowPtr, pic_room_texture, [], topcentral);
        t_room_onset(i)= Screen('Flip', windowPtr, t_fixation_offset1(i)-slack); % show image
        t_room_offset(i)=Screen('Flip', windowPtr, t_room_onset(i)+ room_duration-slack); % show image
        % ---------- Fixation cross 2 ---------- %
        crossLines= [-crossLenght, 0 ; crossLenght, 0; 0 , -crossLenght; 0, crossLenght];
        crossLines= crossLines';
        Screen('DrawLines', windowPtr, crossLines, crossWidth, crossColor, [xCenter, yCenter]);
        t_fixation_onset2(i)=Screen('Flip',windowPtr, t_room_offset(i)-slack);
        t_fixation_offset2(i)=Screen('Flip',windowPtr,t_fixation_onset2(i)+fixation_duration(i,2)-slack);
        % ------- Old/New? ------------%
        Screen('TextSize', windowPtr,50);
        Screen('TextFont', windowPtr,'Helvetica');
        Screen('TextStyle', windowPtr,4);
        % Draw text
        if ConditionB==1
            line1=' Old      New';
        elseif ConditionB==2
            line1=' New      Old';
        end
        DrawFormattedText(windowPtr,line1, 'center','center', textColor);
        t_classification_onset1(i)= Screen('Flip', windowPtr, t_fixation_offset2(i)-slack);
        %Record response
        FlushEvents('keyDown')
        t1 = GetSecs;
        time = 0;
        while time < classification_timeout1
            [keyIsDown,t2,keyCode] = KbCheck; %determine state of keyboard
            time = t2-t1 ;
            if (keyIsDown) %has a key been pressed?
                key = KbName(find(keyCode));
                type= class(key);
                if type == 'cell' %If two keys pressed simultaneously, then 0
                    response_key_question(i,1)= 99;
                    response_kbNum_question(i,1)= 99;
                    response_time_question(i,1)=99;
                elseif key== 'a'
                    response_key_question(i,1)= 1; %if a was pressed, 1
                    response_time_question(i,1) =time;
                    response_kbNum_question(i,1)=  find(keyCode);
                elseif key == 'l'
                    response_key_question(i,1) =2; %if l was pressed, 2
                    response_time_question(i,1) =time;
                    response_kbNum_question(i,1)=  find(keyCode);
                elseif key == 't'
                    events{1, 1}= 'Script aborted' ;
                    events{1, 2}= i ;
                    events{1, 3}= toc(startscript) ;
                    sca %A red error line in the command window will occur:  "Error using Screen".
                end
            end
        end
        t_classification_offset1(i)= Screen('Flip', windowPtr, t_classification_onset1(i)+classification_timeout1-slack);
        % ---------- Fixation cross 3 ---------- %
        crossLines= [-crossLenght, 0 ; crossLenght, 0; 0 , -crossLenght; 0, crossLenght];
        crossLines= crossLines';
        Screen('DrawLines', windowPtr, crossLines, crossWidth, crossColor, [xCenter, yCenter]);
        t_fixation_onset3(i)=Screen('Flip',windowPtr, t_classification_offset1(i)-slack);
        t_fixation_offset3(i)=Screen('Flip',windowPtr,t_fixation_onset3(i)+fixation_duration(i,2)-slack);
        % ------- Sure/Unsure? ------------%
        Screen('TextSize', windowPtr,50);
        Screen('TextFont', windowPtr,'Helvetica');
        Screen('TextStyle', windowPtr,4);
        % Draw text
        line1='Quanto siciuro sei?';
        if ConditionB==1
            line2='\n\n Sicher      Unsicher';
        elseif ConditionB==2
            line2='\n\n Sicher      Unsicher';
        end
        DrawFormattedText(windowPtr,[line1 line2], 'center','center', textColor);
        t_classification_onset2(i)= Screen('Flip', windowPtr, t_fixation_offset3(i)-slack);
        %Record response
        FlushEvents('keyDown')
        t1 = GetSecs;
        time = 0;
        while time < classification_timeout2
            [keyIsDown,t2,keyCode] = KbCheck; %determine state of keyboard
            time = t2-t1 ;
            if (keyIsDown) %has a key been pressed?
                key = KbName(find(keyCode));
                type= class(key);
                if type == 'cell' %If two keys pressed simultaneously, then 0
                    response_key_question(i,2)= 99;
                    response_kbNum_question(i,2)= 99;
                    response_time_question(i,2)=99;
                elseif key== 'a'
                    response_key_question(i,2)= 1; %if a was pressed, 1
                    response_time_question(i,2) =time;
                    response_kbNum_question(i,2)=  find(keyCode);
                elseif key == 'l'
                    response_key_question(i,2) =2; %if l was pressed, 2
                    response_time_question(i,2) =time;
                    response_kbNum_question(i,2)=  find(keyCode);
                elseif key == 't'
                    events{1, 1}= 'Script aborted' ;
                    events{1, 2}= i ;
                    events{1, 3}= toc(startscript) ;
                    sca %A red error line in the command window will occur:  "Error using Screen".
                end
            end
        end
        t_classification_offset2(i)= Screen('Flip', windowPtr, t_classification_onset2(i)+classification_timeout2-slack);
     
        % ---- create last onset variable ------
        t_last_onset(i+1)=t_classification_offset2(i);
        
        % --------- Pauses --------- %
        
        % Intermediate pauses (4 for OA , 2 for YA)
        if i == breakAfterTrials1 || i == breakAfterTrials2 || i == breakAfterTrials3 || i == breakAfterTrials4 || i == breakAfterTrials5 || i == breakAfterTrials6
            Screen('TextSize', windowPtr,50);               %Set text size
            Screen('TextFont', windowPtr,'Helvetica');      %Set font
            Screen('TextStyle', windowPtr,4);               %Set style
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
            t_pause_offset(i)=t_pause_onset(i)+secs-slack; %variable that in the loop becames the fixation timestamp
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

    % Find correct answer to room classification
    answers_classification=[];
    for r=1:length(response_key_question)
        
        if ConditionB ==1
            old = 1;
            new = 2;
        elseif ConditionB ==2
            new = 2;
            old = 1;
        end
        % response_key_question 1 = Ja, 2 = Nein
        % stimuli_list{1, 6}(r, 1), 1 = Task, 0= Control
        
        if response_key_question(r,1) == old && stimuli_list{1, 2}{r, 1} == 3
            answers_classification(r,1)= 31; %Room is old, and answer is "old" : Hit for old room
        elseif response_key_question(r,1) == new && stimuli_list{1, 2}{r, 1} == 4
            answers_classification(r,1)= 32; %Room is new, and answer is "new" : Hit for new room
        elseif response_key_question(r,1) == new && stimuli_list{1, 2}{r, 1} == 3
            answers_classification(r,1)= 41; %Room is old, and answer given is "new" : False alarm for old room
        elseif response_key_question(r,1)== old && stimuli_list{1, 2}{r, 1} == 4
            answers_classification(r,1)= 42; %Room is new, and answer given is "old" : False alarm for new room
            
        elseif response_key_question(r,1) == 99 && stimuli_list{1, 2}{r, 1} == 3
            answers_classification(r,1)= 399; %Multiple response, old room
        elseif response_key_question(r,1) == 99 && stimuli_list{1, 2}{r, 1} == 4
            answers_classification(r,1)= 499;%Multiple response, new room
            
        elseif response_key_question(r,1) == 0 && stimuli_list {1, 2}{r, 1} == 3
            answers_classification(r,1)= 30; %No response to old rooms
        elseif response_key_question(r,1) == 0 && stimuli_list {1, 2}{r, 1} == 4
            answers_classification(r,1)= 40; %No response to new rooms
        end
    end

%% 11. Resume

       
    % Total results
    results.hintsOld=sum(answers_classification==31);
    results.hintsNew=sum(answers_classification==41);
    
    results.errorsOld=sum(answers_classification==32);
    results.errorsNew=sum(answers_classification==42);
    
    results.missedOld=sum(answers_classification==30);
    results.missedNew=sum(answers_classification==40);
    
    results.multipleOld=sum(answers_classification==399);
    results.multipleNew=sum(answers_classification==499);
    
    results.totalresponseOld=sum(results.hintsOld+results.errorsOld); 
    results.totalresponseNew=sum(results.hintsNew+results.errorsNew); 

%% 12. Save
stimuli.stimuli_randomized= stimuli_list;
stimuli.row_randomization= rows_rand;
stimuli.labels={'Room picture name','Old(3) or new(4)?'};

answer.response_kbNum=response_kbNum_question;
answer.response_key  =response_key_question;
answer.response_time =response_time_question;
answer.all_answers   = answers_classification; %indoor vs outdoor first columns, sure unsure, the second

timing.end=(time_end/60); %from seconds to minutes (are now in msec because calculated by Matlab)
timing.pause=time_pause/60;
timing.last_backup=time_lastbackup/60;
timing.fixation_onset1=t_fixation_onset1; % fixation crosses (n=2)
timing.fixation_offset1=t_fixation_offset1;
timing.fixation_onset2=t_fixation_onset2; 
timing.fixation_offset2=t_fixation_offset2;
timing.fixation_onset3=t_fixation_onset3; 
timing.fixation_offset3=t_fixation_offset3;
timing.classification_onset1=t_classification_onset1;
timing.classification_offset1=t_classification_offset1;
timing.classification_onset2=t_classification_onset2;
timing.classification_offset2=t_classification_offset2;
timing.ISI_fixation_duration=fixation_duration;
timing.room_onset=t_room_onset; % room
timing.room_offset=t_room_offset;
timing.end_onset=t_end_onset; %end screen
timing.end_offset=t_end_offset;
timing.slack=slack; % slack (difference between screen flip and VBL)


participant_info.ID=ID;
participant_info.age_group=Group;
participant_info.group_ISI=ConditionA;
participant_info.answers_presentation=ConditionB;



%% 13. Save results
save([path.res num2str(ID) '_' num2str(Session) '.mat']...
    , 'participant_info' ...
    , 'stimuli' ...
    , 'results' ...
    , 'answer' ...
    , 'timing' );


