%% Settings for experiment
% Change these to modify main characteristics

% Synchronization (2 if in Mac environment, 1 in widonws to disable it. 0 if you want the synchro) 
Screen('Preference','SkipSyncTests', 2);

% Keyboard settings
KbName('UnifyKeyNames');

% Response keys (optional; for no subject response use empty list)
activeKeys = [KbName('a') KbName('space') KbName('l')  KbName('t')];

%Pictures dimensions
gap=0; %gap between top of the screen and room
picHeight=600; %measure of room picutures
picWidth=800;
gapHeight= 0; %gap between main room image and choice options (alternative 1, 2 and lure)
objpicHeight=250; %measure of objects
objpicWidth=250;

%Fixation cross dimensions
crossLenght = 10;
crossWidth= 3;

% Number of trials
numTrials=6;

% Number of trials to show before a break (for no breaks, choose a number
% greater than the number of trials in your experiment)
breakAfterHalfTrials = numTrials;

% Background color: choose a number from 0 (black) to 255 (white)
backgroundColor = 0;

% Text color: choose a number from 0 (black) to 255 (white)
textColor = 255;
crossColor = 255;

% How long (in seconds) each image in the ENCODING task will stay on screen
room_duration = 7; %seconds
selection_timeout = 3; %3000 msec in youngs, 3500 in old max
feedback_duration = 3; 
emopic_duration= 5;
fixation_duration_1= 3; 
fixation_duration_2= 2; 
fixation_duration_3= 1; 
fixation_duration_4= 2; 
fixation_duration_5=2;
classification_timeout=3;

% Timeout settings
RestrictKeysForKbCheck(activeKeys);
ListenChar(2); % suppress echo to the command line for keypresses (https://de.mathworks.com/matlabcentral/answers/310311-how-to-get-psychtoolbox-to-wait-for-keypress-but-move-on-if-it-hasn-t-recieved-one-in-a-set-time)

