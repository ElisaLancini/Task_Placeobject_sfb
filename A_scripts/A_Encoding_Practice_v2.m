%% (A) Encoding - Practice session

% Fixation cross 1,2,3 = ISI
% Room                 = 7
% Selection            = 3
% Feedback             = 3
% Fixation cross 4     = 2
% EmoPic               = 5
% Classification       = 3


%6 stimuli * 2 = 12
% pause after 6 stimuli
% response recording

clearvars
clc
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
ConditionB  = str2num(input_answer{3,1}); % Ja / Nein
Group       = str2num(input_answer{4,1}); % Age group
Session     = str2num(input_answer{5,1}); % stimuli from previous task to be presented

% Check if is the experimenter is using the right script
if Session ~= 1
    errordlg('You are running the wrong script','Session error');
    return
end

% Check if Conditions are >1 and <2 , otherwise error will occur

if ConditionA > 2 || ConditionB > 2 || ConditionA == 0 || ConditionB == 0
    errordlg('Condition does not eist, check','Condition error');
    return
end

clear input_answer
%% 3. Load settings
cd(path.input)
Settings_encoding_practice;

%% 4. Pre allocate variables

response_key=zeros(numTrials*2,1); %Key pressed
response_key_question=zeros(numTrials,1);

response_time=zeros(numTrials*2,1); %Time of key press
response_time_question=zeros(numTrials,1);

response_kbNum=zeros(numTrials*2,1); %Number of key pressed
response_kbNum_question=zeros(numTrials,1);

idx=[]; %Index of cue of the first block (cue 1 or cue 2?)
time_pause=zeros(1,140);
time_end=999;
events=cell(1,2);

%% 5. Load stimuli list (inputfile)

load('inputfile.mat');
inputfile=uploadedfile;
clear uploadedfile
load('inputfile_new.mat');
inputfile_newstim=uploadedfile;
load('inputfile_emopics_negative.mat');
inputfile_emopics_negative=uploadedfile;
clear uploadedfile
load('inputfile_emopics_neutral.mat');
inputfile_emopics_neutral=uploadedfile;


%% 6. Randomization

% ---------- Randomize cue 1 or 2 presentation in block 1 or 2 ! -------- %
%                        (stimuli_list)


stimuli_list= cell(1,8); %Create the variable stimuli_list

% 1. Choose external lure (counterbalanced by ID odd/even) %
if mod(ID,2)== 0
    first_block_external_lure= inputfile{1, 6};
    second_block_external_lure= inputfile{1, 7};
else
    first_block_external_lure= inputfile{1, 7};
    second_block_external_lure= inputfile{1, 6};
end

% 2. Randomize cue (left or right object?) and randomize stimuli order (randomization)

% 2.1 Randomize rows (rooms and emotional stimuli)
idx= randi(2,numTrials,1); % create vector with random 1 and 2, that represents cue type 1 or 2 for each row
idx_emopic = mod( reshape(randperm(numTrials*1), numTrials, 1), 2 ); % index for emotional pictures, 50% type 1 50% type 2 

% -----
% 2.1 Randomize rows (rooms and emotional stimuli)
idx= randi(2,numTrials,1); % create vector with random 1 and 2, that represents cue type 1 or 2 for each row
idx_emopic = mod( reshape(randperm(numTrials*1), numTrials, 1), 2 ); % index for emotional pictures, 50% type 1 50% type 2 
rows1=(1:numTrials); % create vector with all row numbers in order (from 1 to 50)
rows_rand1=rows1(randperm(length(rows1)))'; % Randomize the order of the numbers in this vector
rows2=(numTrials+1:numTrials*2); % create vector with all row numbers in order (from 51 to 100)
rows_rand2=rows2(randperm(length(rows2)))'; % Randomize the order of the numbers in this vector
rows_rand=[rows_rand1;rows_rand2]; % randomized rows in block 1 and block 2 together.
rows_emopics_neutral=1:numTrials; % emopics
rows_emopics_negative=1:numTrials;
rows_rand_emopics_neutral=(rows_emopics_neutral(randperm(length(rows_emopics_neutral))))';
rows_rand_emopics_negative=(rows_emopics_negative(randperm(length(rows_emopics_negative))))';

clear rows1 rows2

% 2.2 Re-order stimuli

% 2.2 Re-order every row depending on the new row list and randomize cue
for n=1:numTrials %
    x= rows_rand1(n);
    % Re-order first column (Rooms)
    stimuli_list{1, 1}{x, 1} = inputfile{1, 1}{n, 1};
    % Re-order sixth column (Type of stimulus)
    stimuli_list{1, 6}{x, 1} = idx_emopic(n);
    %Randomize other columns (Objects, type of trial)
    if idx(x)==1
        stimuli_list{1, 2}{x, 1} = inputfile{1, 2}{n, 1};  %cue 1
        stimuli_list{1, 3}{x, 1} = inputfile{1, 4}{n, 1};  %dependeing on cue, this is the right object
        stimuli_list{1, 4}{x, 1} = inputfile{1, 5}{n, 1};  %internal lure (alternative 2)
        stimuli_list{1, 5}{x, 1} = first_block_external_lure{n, 1};  %external lure 1
    else
        stimuli_list{1, 2}{x, 1} = inputfile{1, 3}{n, 1}; %cue 2
        stimuli_list{1, 3}{x, 1} = inputfile{1, 5}{n, 1}; %object 2
        stimuli_list{1, 4}{x, 1} = inputfile{1, 4}{n, 1}; %internal lure (alternative 1)
        stimuli_list{1, 5}{x, 1} = first_block_external_lure{n, 1}; %external lure 2
    end
    %Create second block of stimuli(alternatives of the first block)
    y= rows_rand2(n);
    %Randomize first column (Rooms)
    stimuli_list{1, 1}{y, 1} = inputfile{1, 1}{n, 1};
    %Randomize other columns (Objects, type of trial)
    if  idx(x,1)==1 %If before it was 1... now is 2
        stimuli_list{1, 2}{y, 1} = inputfile{1, 3}{n, 1}; %cue 2
        stimuli_list{1, 3}{y, 1} = inputfile{1, 5}{n, 1}; %object 2
        stimuli_list{1, 4}{y, 1} = inputfile{1, 4}{n, 1}; %internal lure (alternative 1)
        stimuli_list{1, 5}{y, 1} = second_block_external_lure{n, 1}; %external lure 2
        idx(y,1)=2; % ...save as 2
    else %if before was 2...now is 1
        stimuli_list{1, 2}{y, 1} = inputfile{1, 2}{n, 1};  %cue 1
        stimuli_list{1, 3}{y, 1} = inputfile{1, 4}{n, 1};  %dependeing on cue, this is the right object
        stimuli_list{1, 4}{y, 1} = inputfile{1, 5}{n, 1};  %internal lure (alternative 2)
        stimuli_list{1, 5}{y, 1} = second_block_external_lure{n, 1};  %external lure 1
        idx(y,1)=1; %...save as 1
    end
    %2.3 randomize emopic 
    if stimuli_list{1,6}{x, 1}==1
        stimuli_list{1,6}{y, 1} = 1;
    else
        stimuli_list{1,6}{y, 1} = 0; 
    end
end

% Add concatenated indexes in the 7th column (cue 1 or 2?)
stimuli_list{:, 7}=num2cell(idx);
clear type x y n

% 3. EmoPic for each row (order of emopics is randomized )

 where_ones= (find([stimuli_list{1, 6}{:, 1}] == 1))'; % where are supposed to be negative and neutral stimuli?
 where_zeros=(find([stimuli_list{1, 6}{:, 1}] == 0))';
 for x=1:numTrials
 stimuli_list{1, 8}{where_ones (x), 1} = inputfile_emopics_negative{1, 1}{rows_rand_emopics_negative(x), 1};
 stimuli_list{1, 8}{where_zeros(x), 1} = inputfile_emopics_neutral{1, 1}{rows_rand_emopics_neutral(x), 1};
 end
 
 for i=1:numTrials
 new_position_inputfiles{i, 1}=inputfile{1, 1}{i, 1};
 new_position_inputfiles{i, 2}=rows_rand1(i,1);
 new_position_inputfiles{i, 3}=rows_rand2(i,1);
 new_position_inputfiles{i, 4}=stimuli_list{1, 1}{i, 1};
 new_position_inputfiles{i, 5}=stimuli_list{1, 1}{i+numTrials, 1};
 new_position_inputfiles{i, 6}=stimuli_list{1, 6}{i, 1}; % type of emopic block 1
 new_position_inputfiles{i, 7}=stimuli_list{1, 6}{i+numTrials, 1}; % type of emopic block 2
 new_position_inputfiles{i, 8}=stimuli_list{1, 8}{i, 1}; % emopic name
 new_position_inputfiles{i, 9}=stimuli_list{1, 8}{i+numTrials, 1}; %emopicname
 new_position_inputfiles{i, 10}=stimuli_list{1, 7}{i, 1}; % type of cue block 1
 new_position_inputfiles{i, 11}=stimuli_list{1, 7}{i+numTrials, 1}; % type of cue block 2
 end
 
header={'Inputfile_name', 'first_block_pos','second_block_pos','first_block_name','second_block_name','emopic_type_block1','emopic_type_block2','first_block_emopic','second_block_emopic','cue_type_block1','cue_type_block2'};
new_position_inputfiles_table=cell2table(new_position_inputfiles,'VariableNames',header);
clear header 

% --------------  Randomize stimuli position on the screen -------------- %

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
for x=1:(numTrials*2)
    stimuli_choice_pos(x,:)=Shuffle(where);
end

%% 7. Save randomization information
save([path.res num2str(ID) '_' num2str(Session) '_randinfo.mat']);
%% TASK
% try
%% ------ Welcome screen ------ %
Screen('TextSize', windowPtr,50);               %Set text size
Screen('TextFont', windowPtr,'Helvetica');      %Set font
Screen('TextStyle', windowPtr,4);               %Set style
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

for i = 1:numTrials*2
    % ---------- Fixation cross 1 ---------- %
    crossLines= [-crossLenght, 0 ; crossLenght, 0; 0 , -crossLenght; 0, crossLenght];
    crossLines= crossLines';
    Screen('DrawLines', windowPtr, crossLines, crossWidth, crossColor, [xCenter, yCenter]);
    t_fixation_onset1(i)=Screen('Flip',windowPtr, t_last_onset(i)-slack);
    t_fixation_offset1(i)=Screen('Flip',windowPtr,t_fixation_onset1(i)+fixation_duration_1-slack);
    % ---------------- Room ---------------- %
    pic_room=imread([path.sti stimuli_list{1, 1}{i, 1}], 'jpg');
    pic_room_texture=Screen('MakeTexture', windowPtr, pic_room);
    Screen('DrawTexture', windowPtr, pic_room_texture, [], topcentral);
    t_room_onset(i)= Screen('Flip', windowPtr, t_fixation_offset1(i)-slack); % show image
    t_room_offset(i)= Screen('Flip', windowPtr, t_room_onset(i)+room_duration-slack); % show image
    % ---------- Fixation cross 2 ---------- %
    crossLines= [-crossLenght, 0 ; crossLenght, 0; 0 , -crossLenght; 0, crossLenght];
    crossLines= crossLines';
    Screen('DrawLines', windowPtr, crossLines, crossWidth, crossColor, [xCenter, yCenter]);
    t_fixation_onset2(i)=Screen('Flip',windowPtr, t_room_offset(i)-slack);
    t_fixation_offset2(i)=Screen('Flip',windowPtr,t_fixation_onset2(i)+fixation_duration_2-slack);
    % ---------------- Selection ---------------- %
    % Select which picture to read
    pic_cue=imread([path.sti stimuli_list{1, 2}{i, 1}], 'png');  %load cue
    pic_alt1=imread([path.sti stimuli_list{1, 3}{i, 1}], 'jpg'); % object
    pic_alt2=imread([path.sti stimuli_list{1, 4}{i, 1}], 'jpg'); % internal lure
    pic_lure=imread([path.sti stimuli_list{1, 5}{i, 1}], 'jpg'); % external lure
    %Make textures of them
    pic_cue_texture=Screen('MakeTexture', windowPtr, pic_cue);
    pic_alt1_texture=Screen('MakeTexture', windowPtr, pic_alt1);
    pic_alt2_texture=Screen('MakeTexture', windowPtr, pic_alt2);
    pic_lure_texture=Screen('MakeTexture', windowPtr, pic_lure);
    % Put them toghtether (....if you want to present them in the same screen)
    pics=[pic_cue_texture pic_alt1_texture pic_alt2_texture pic_lure_texture]';
    % Concatenate position of the pics
    positions=[topcentral' , stimuli_choice_pos{i, 1}' , stimuli_choice_pos{i, 2}' , stimuli_choice_pos{i, 3}'];
    % Flip (draw all toghether)
    Screen('DrawTextures', windowPtr, pics, [], positions);
    t_selection_onset(i)= Screen('Flip', windowPtr,  t_room_offset(i)-slack);
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
                keypressed = find(keyCode);
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
    time_lastbackup(i)=toc(startscript);
    % Backup of answers after every keypressed
    save([path.res num2str(ID) '_' num2str(Session) '_backup.mat']);
    % ---------- Fixation cross 3 ---------- %
    crossLines= [-crossLenght, 0 ; crossLenght, 0; 0 , -crossLenght; 0, crossLenght];
    crossLines= crossLines';
    Screen('DrawLines', windowPtr, crossLines, crossWidth, crossColor, [xCenter, yCenter]);
    t_fixation_onset3(i)=Screen('Flip',windowPtr,t_selection_offset(i)-slack);
    t_fixation_offset3(i)=Screen('Flip',windowPtr,t_fixation_onset3(i)+fixation_duration_3-slack);
    % ---------------- Feedback ------ %
    Screen('DrawTexture', windowPtr, pic_room_texture, [], topcentral);
    t_feedback_onset(i)= Screen('Flip', windowPtr, t_fixation_offset3(i)-slack); % show image
    t_feedback_offset(i)= Screen('Flip', windowPtr, t_feedback_onset(i)+feedback_duration-slack); % show image
    % ---------- Fixation cross 4 ---------- %
    crossLines= [-crossLenght, 0 ; crossLenght, 0; 0 , -crossLenght; 0, crossLenght];
    crossLines= crossLines';
    Screen('DrawLines', windowPtr, crossLines, crossWidth, crossColor, [xCenter, yCenter]);
    t_fixation_onset4(i)=Screen('Flip',windowPtr, t_feedback_offset(i)-slack);
    t_fixation_offset4(i)=Screen('Flip',windowPtr,t_fixation_onset4(i)+fixation_duration_4-slack);
    % ---------------- EmoPics ------ %
    pic_emo=imread([path.emopics stimuli_list{1, 8}{i, 1}], 'jpg');
    pic_emo_texture=Screen('MakeTexture', windowPtr, pic_emo);
    Screen('DrawTexture', windowPtr, pic_emo_texture, [], topcentral);
    t_emopic_onset(i)= Screen('Flip', windowPtr, t_fixation_offset4(i)-slack); % show image
    t_emopic_offset(i)= Screen('Flip', windowPtr, t_emopic_onset(i)+emopic_duration-slack); % show image
    % ---------- Fixation cross 4 ---------- %
    crossLines= [-crossLenght, 0 ; crossLenght, 0; 0 , -crossLenght; 0, crossLenght];
    crossLines= crossLines';
    Screen('DrawLines', windowPtr, crossLines, crossWidth, crossColor, [xCenter, yCenter]);
    t_fixation_onset5(i)=Screen('Flip',windowPtr, t_emopic_offset(i)-slack);
    t_fixation_offset5(i)=Screen('Flip',windowPtr,t_fixation_onset5(i)+fixation_duration_5-slack);
    % ------- Indoor/Outdoor? ------------% 
        Screen('TextSize', windowPtr,50);
        Screen('TextFont', windowPtr,'Helvetica');
        Screen('TextStyle', windowPtr,4);
        % Draw text
        if ConditionB==1
            line1=' Indoor      Outdoor';
        elseif ConditionB==2
            line1=' Outdoor      Indoor';
        end
        DrawFormattedText(windowPtr,line1, 'center','center', textColor);
        t_classification_onset(i)= Screen('Flip', windowPtr, t_fixation_offset5(i)-slack);
        %Record response
        FlushEvents('keyDown')
        t1 = GetSecs;
        time = 0;
        while time < classification_timeout
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
        t_classification_offset(i)= Screen('Flip', windowPtr, t_classification_onset(i)+classification_timeout-slack);
    
    % ---- create last onset variable ------
    t_last_onset(i+1)=t_classification_offset(i);

    % --------- Pauses --------- %
    
    % Intermediate pauses (4 for OA , 2 for YA)
    if i== breakAfterHalfTrials
        line1='Die Halfte des Experiments ist abgeschlossen.';              %Set text, location (xy)and color
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
Screen('TextStyle', windowPtr,4); %Set style
DrawFormattedText(windowPtr,'Vielen Dank fur Ihre Teilnahme', 'center','center', textColor); %Set text, location (xy)and color
t_end_onset=Screen('Flip', windowPtr, t_feedback_offset(i)-slack);     %Show the results on the screen
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
    for r = 1:(numTrials*2)
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
for i = 1:numTrials*2
    
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
timing.fixation_onset1=t_fixation_onset1; % fixation crosses (n=4)
timing.fixation_offset1=t_fixation_offset1;
timing.fixation_onset2=t_fixation_onset2; 
timing.fixation_offset2=t_fixation_offset2;
timing.fixation_onset3=t_fixation_onset3;  
timing.fixation_offset3=t_fixation_offset3;
timing.fixation_onset4=t_fixation_onset4;  
timing.fixation_offset4=t_fixation_offset4;
timing.fixation_onset5=t_fixation_onset5;  
timing.fixation_offset5=t_fixation_offset5;
% timing.ISI_fixation_duration=fixation_duration;
timing.room_onset=t_room_onset; % room
timing.room_offset=t_room_offset;
timing.selection_onset=t_selection_onset; % selection
timing.selection_offset=t_selection_offset;
timing.feedback_onset=t_feedback_onset; % feedback
timing.feedback_offset=t_feedback_offset;
timing.emopic_onset=t_emopic_onset; % emoPics
timing.emopic_offset=t_emopic_offset;
timing.classification_onset=t_classification_onset; % classification
timing.classification_offset=t_classification_offset;
timing.end_onset=t_end_onset; %end screen
timing.end_offset=t_end_offset;
timing.slack=slack; % slack (difference between screen flip and VBL)


participant_info.ID=ID;
participant_info.age_group=Group;
participant_info.group_ISI=ConditionA;
participant_info.aswers_presentation=ConditionB;


new_position_inputfiles_table;
%% 13. Save results
save([path.res num2str(ID) '_' num2str(Session) '.mat']...
    , 'participant_info' ...
    , 'stimuli' ...
    , 'results' ...
    , 'answer' ...
    , 'timing' );

%% Show results 
errornum=results.falseallarm+results.errors+results.missed;
message = sprintf('Fehlernummern = %d', errornum );
msgbox(message);
    
