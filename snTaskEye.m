%% notes
% ctrl +c to stop the experiment
% sca for closing the window


%--------------------------------------------------------------------------
% Initial Setup
%--------------------------------------------------------------------------
try
    % clear the workspace and the screen
    close all;
    clear;
    
    %%%%%
    % if you want to do eye tracking, set this to one, otherwise, set it to 0
    trackEye = 0;
    if trackEye == 1
        %%Eye-Tracking Options
        fixSize = 5; %radius of fixation dot
    end
    %%%%%
    
    %%%%% check for the operating system
    if trackEye == 1
        KbName('UnifyKeyNames');
        if IsOSX==1
            TopPriority=0;
            sysTxtOff=0;  % no text adjustment needed
            ptbPipeMode=kPsychNeedFastBackingStore;  % enable imaging pipeline for osx
        elseif IsWin==1
            TopPriority=1;
            sysTxtOff=1;  % windows draws text from the upper left corner instead of lower left.  to correct,
            % an adjustment factor of 1*letterheight is subtracted
            % from the y coordinate of the starting point
            ptbPipeMode=[];  % don't need to enable imaging pipeline
        else
            ListenChar(0); clear screen; error('Operating system not OS X or Windows.')
        end
        
        if IsWin==1
            skipSync = 0;
        else
            skipSync = 0; %if necessary to skip sync
        end %if ispc
    end
    %%%%%
    
    %%%%%
    if trackEye == 1
        % keyboard
        if IsOSX==1
            enterButton=[KbName('enter') KbName('return')];
        else
            enterButton=KbName('return');
        end %if ismac
    end
    %%%%%
    
    % enter subject data
    rng('shuffle');
    sesInfo = inputdlg({'Subject ID:','Name:','Venmo or Paypal Account:'}, 'Subject Details', [1 7; 1 40; 1 40]);
    %sesInfo = inputdlg({'Subject ID:'},'Subject Details',1,{'1'});
    sID     = str2num(sesInfo{1});
    nameID  = sesInfo{2};
    venmoID = sesInfo{3};
    
    
    
    %--------------------------------------------------------------------------
    % Set up Eyetracker
    %--------------------------------------------------------------------------
    %%%%%
    %  if trackEye == 1
    %     % make file for eyetracking data
    %     %%% eyetracking  data %%%
    %     rootDir = cd;
    %     expName='dl';
    %     baseName=[num2str(sID),'_',expName];
    %     if trackEye == 1
    %         fileName = [baseName '_eyeTrackingData' '.csv'];
    %         eyeTrackDataFile = fopen(fileName, 'a');
    %         eyeLabel = '%s, %s, %s,%s,%s,%s,%s\n';
    %         fprintf(eyeTrackDataFile, eyeLabel, ...
    %             'Type','Part','sID', 'trial', 'look', 'fixStart', 'fixEnd');
    %     end
    %  end
    %%%%%
    
    
    % call some default settings for setting up Psychtoolbox
    PsychDefaultSetup(2);
    Screen('Preference', 'SkipSyncTests', 1);
    
    % screen numbers
    screens = Screen('Screens');
    
    % draw to the external screen if avaliable
    screenNumber = max(screens);
    
    % define colors
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    gray = GrayIndex(screenNumber);
    greycol = 150;
    
    cyan        = [0.2 0.8 0.8];
    brown       = [0.2 0 0];
    
    orange      = [1 0.5 0];
    blue        = [0 0.5 1];
    green       = [0 0.6 0.3];
    red         = [1 0.2 0.2];
    lightred    = [1.0000 0.2902 0.2902];
    pink        = [1.0000 0.0745 0.6510];
    
    lightGrey1   = [0.85 0.85 0.85];
    lightGrey2   = [0.7 0.7 0.7];
    darkGrey1  = [0.4 0.4 0.4];
    darkGrey2  = [0.2 0.2 0.2];
    
    % screen and text color
    backgroundColor = black;
    textColor = white;
    fixColor = white;
    numberColor = white;
    frameColorSelf = blue;
    frameColorOther = white;
    frameColorSelfControl = black;
    sliderColor = white;
    mainSize = 40;
    mainFont = 'Arial';
    shiftNumberUpControl = 20;
    shiftNumberDownControl = 60;
    shiftNumberUp = 10;
    shiftNumberDown = 40;
    
    
    % screen visuals
    fixThresh = 150; % can look 50 pixels away from fixation before it gets mad
    
    % Open an on screen window
    % for testing smaller screen size
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, backgroundColor, []);
    %[window, windowRect] = PsychImaging('OpenWindow', screenNumber, backgroundColor, [480 0 1440 600]);
    %[window, windowRect] = PsychImaging('OpenWindow', screenNumber, backgroundColor, [0 0 1824 1026]);
    %[window, windowRect] = PsychImaging('OpenWindow', screenNumber, backgroundColor, [0 0 1680 1050]);
    
    % text styles
    Screen('TextFont', window,'Arial');
    Screen('TextSize', window,30);
    Screen('TextStyle', window,1);
    
    % The avaliable keys to press
    escapeKey = KbName('ESCAPE');
    upKey = KbName('UpArrow');
    downKey = KbName('DownArrow');
    leftKey = KbName('LeftArrow');
    rightKey = KbName('RightArrow');
    secretKey = KbName('j');
    secretKeyConsent = KbName('c');
    secretKeyEnd = KbName('s');
    expKey = KbName('e');
    
    %--------------------------------------------------------------------------
    % Design
    %--------------------------------------------------------------------------
    % generate control trials design
    [expDesignControl0, expNoSocialInfoControl0] = snGenDesignControl();
    
    % generate experiment design
    [expDesign, expDesignControl1, expSocialInfo, expNoSocialInfoControl1] = snGenDesign();
    
    
    %--------------------------------------------------------------------------
    % Define Rectangular Coordinates Main Task
    %--------------------------------------------------------------------------
    
    globalRect = windowRect;
    [midX,midY] = RectCenter(windowRect);
    
    ScreenX = globalRect(3); % x-axis length
    ScreenY = globalRect(4); % y-axis length
    
    % numRect = define number of rectangles on the screen where images will be placed
    % globalRect = size of the screen as [0 0 1440 900]
    numRects = [3,3];
    rectSize   = windowRect(4);
    
    %images occupy
    xBias      = 0; %(globalRect(3) - rectSize)/2;
    yBias      = 0;
    
    % length of the small boxes where images are placed
    yLength    = windowRect(4)/numRects(1);
    xLength    = windowRect(3)/numRects(2);
    
    midyLength = yLength/2;
    midxLength = xLength/2;
    
    yLengthSlider = 6;
    xLengthSlider = xLength*(5/6);
    
    
    % rectCount = counts the rectangles already used
    % rectC = exact coordinates of the small rectangles
    rectC = zeros(numRects(1)*numRects(2),4);
    rectCount = 0;
    for i = 1:numRects(1) % rows
        for ii = 1:numRects(2) % cols
            rectCount = rectCount + 1;
            xStart = (ii-1)*xLength + xBias;
            yStart = (i-1)*yLength  + yBias;
            xEnd   = xStart + xLength;
            yEnd   = yStart + yLength;
            
            rectC(rectCount,:) = [xStart, yStart, xEnd, yEnd];
            
        end
    end
    
    % rectS = exact coordinates of the sliders for each rectangle
    rectS = zeros(numRects(1)*numRects(2),4);
    sliderCount = 0;
    for i = 1:numRects(1) % rows
        for ii = 1:numRects(2) % cols
            sliderCount = sliderCount + 1;
            
            midxRect = rectC(sliderCount,1) + (rectC(sliderCount,3)-rectC(sliderCount,1))/2;
            midyRect = rectC(sliderCount,2) + (rectC(sliderCount,4)-rectC(sliderCount,2))/2;
            
            xStartSlider = midxRect - xLengthSlider/2;
            yStartSlider = midyRect - yLengthSlider/2;
            xEndSlider   = midxRect + xLengthSlider/2;
            yEndSlider   = midyRect + yLengthSlider/2;
            
            rectS(sliderCount,:) = [xStartSlider, yStartSlider, xEndSlider, yEndSlider];
            % rectB(sliderCount,:) = [midxRect-2, midyRect-5, midxRect+2, midyRect+5];
        end
    end
    
    % rectB = social info - slider position
    rectB = zeros(size(expDesign,1),numRects(1)*numRects(2),4);
    for trial = 1:size(expDesign,1)
        ansRectTrial = expDesign(trial,12);
        socInfoCount = 0;
        for s = 1:9
            midxRect = rectC(s,1) + (rectC(s,3)-rectC(s,1))/2;
            midyRect = rectC(s,2) + (rectC(s,4)-rectC(s,2))/2;
            
            if(s~=ansRectTrial)
                socInfoCount = socInfoCount + 1;
                rectB(trial,s,1) = rectS(s,1) + (expSocialInfo(trial,socInfoCount)/100)*xLengthSlider - 2;
                rectB(trial,s,3) = rectS(s,1) + (expSocialInfo(trial,socInfoCount)/100)*xLengthSlider + 2;
                rectB(trial,s,2) = midyRect - 5;
                rectB(trial,s,4) = midyRect + 5;
            else
                rectB(trial,s,1) = midxRect - 2;
                rectB(trial,s,3) = midxRect + 2;
                rectB(trial,s,2) = midyRect - 5;
                rectB(trial,s,4) = midyRect + 5;
            end
        end
    end
    
    
    
    % 5 top labels - for each rectangle (9) total
    posLabelsTop = zeros(5,numRects(1)*numRects(2),2);
    posLabelsBottom = zeros(5,numRects(1)*numRects(2),2);
    rectCount = 0;
    for i = 1:numRects(1) % rows
        for ii = 1:numRects(2) % cols
            rectCount = rectCount + 1;
            % label number
            k = [0, 1, 2, 3, 4];
            posLabelsTop(:,rectCount,1) = rectS(rectCount,1) + xLengthSlider*(k/4);
            posLabelsTop(:,rectCount,2) = rectS(rectCount,2) - 5;
            posLabelsBottom(:,rectCount,1) = rectS(rectCount,1) + xLengthSlider*(k/4);
            posLabelsBottom(:,rectCount,2) = rectS(rectCount,4) + 5 + 5;
        end
    end
    
    
    %--------------------------------------------------------------------------
    % Define Rectangular Coordinates Control Task
    %--------------------------------------------------------------------------
    
    % rectangle position
    xLengthControl = windowRect(3);
    yLengthControl = windowRect(4);
    
    xStartControl = 0;
    yStartControl = 0;
    xEndControl   = xStartControl + xLengthControl;
    yEndControl   = yStartControl + yLengthControl;
    rectCcontrol = [xStartControl, yStartControl, xEndControl, yEndControl];
    
    % slider position
    yLengthSliderControl = 6;
    xLengthSliderControl = xLengthControl*(5/6);
    
    midxRectControl = rectCcontrol(1,1) + (rectCcontrol(1,3)-rectCcontrol(1,1))/2;
    midyRectControl = rectCcontrol(1,2) + (rectCcontrol(1,4)-rectCcontrol(1,2))/2;
    
    xStartSliderControl = midxRectControl - xLengthSliderControl/2;
    yStartSliderControl = midyRectControl - yLengthSliderControl/2;
    xEndSliderControl   = midxRectControl + xLengthSliderControl/2;
    yEndSliderControl   = midyRectControl + yLengthSliderControl/2;
    
    rectScontrol = [xStartSliderControl, yStartSliderControl, xEndSliderControl, yEndSliderControl];
    
    % slider tick mark position
    rectBcontrol = [midxRectControl - 2, midyRectControl - 5, midxRectControl + 2, midyRectControl + 5];
    
    % labels position
    posLabelsTopControl = zeros(5,1,2);
    posLabelsBottomControl = zeros(5,1,2);
    % label number
    k = [0, 1, 2, 3, 4];
    posLabelsTopControl(:,1,1) = rectScontrol(1,1) + xLengthSliderControl*(k/4);
    posLabelsTopControl(:,1,2) = rectScontrol(1,2) - 5;
    posLabelsBottomControl(:,1,1) = rectScontrol(1,1) + xLengthSliderControl*(k/4);
    posLabelsBottomControl(:,1,2) = rectScontrol(1,4) + 5 + 5;
    
    
    %--------------------------------------------------------------------------
    % Define Rectangular Coordinates Fixation Cross
    %--------------------------------------------------------------------------
    % fixation cross parameters
    fixWidth    = 3.75;
    fixHeight   = 30;
    
    FixCross    = [midX-fixWidth, midY-fixHeight ,midX+fixWidth, midY+fixHeight;
        midX-fixHeight, midY-fixWidth, midX+fixHeight, midY+fixWidth];
    
    
    
    %%%%%
    if trackEye == 1
        % AOI with margins
        rectAOI(1,:) = calcAOI(rectC(1,:),ScreenX,ScreenY,0,0);
        rectAOI(2,:) = calcAOI(rectC(2,:),ScreenX,ScreenY,0,0);
        rectAOI(3,:) = calcAOI(rectC(3,:),ScreenX,ScreenY,0,0);
        rectAOI(4,:) = calcAOI(rectC(4,:),ScreenX,ScreenY,0,0);
        rectAOI(5,:) = calcAOI(rectC(5,:),ScreenX,ScreenY,0,0);
        rectAOI(6,:) = calcAOI(rectC(6,:),ScreenX,ScreenY,0,0);
        rectAOI(7,:) = calcAOI(rectC(7,:),ScreenX,ScreenY,0,0);
        rectAOI(8,:) = calcAOI(rectC(8,:),ScreenX,ScreenY,0,0);
        rectAOI(9,:) = calcAOI(rectC(9,:),ScreenX,ScreenY,0,0);
    end
    %%%%%
    
    %--------------------------------------------------------------------------
    % Consent Form
    %--------------------------------------------------------------------------
    
    % load images
    imagesConsent = snLoadConsent;
    nrImagesConsent = size(imagesConsent,1);
    
    % create textutes
    for i = 1:size(imagesConsent,1)
        texturesConsent{i,1} = Screen('MakeTexture',window,imagesConsent(i,1).img);
    end
    
    % draw the first texture
    ind = 1;
    secretConsent = 0;
    while (secretConsent==0)
        if(ind<=1)
            ind = 1;
            Screen('DrawTexture', window, texturesConsent{ind, 1});
            Screen('flip',window);
            ind = 2;
        end
        
        [secs, keyCode, deltaSecs] = KbWait([],2);
        
        if(keyCode(rightKey))
            
            keyCode(rightKey) = 0;
            
            ind = ind + 1;
            Screen('DrawTexture', window, texturesConsent{ind, 1});
            Screen('flip',window);
            if(ind==nrImagesConsent)
                ind = ind - 1;
            end
            
        elseif(keyCode(leftKey))
            
            keyCode(leftKey) = 0;
            
            if(ind<=0)
                Screen('DrawTexture', window, texturesConsent{1, 1});
                Screen('flip',window);
            else
                Screen('DrawTexture', window, texturesConsent{ind-1, 1});
                Screen('flip',window);
                
            end
            ind = ind - 1;
        elseif(keyCode(secretKeyConsent))
            secretConsent = 1;
        else
            continue
        end
        
        
    end
    
    
    
    %--------------------------------------------------------------------------
    % Instructions
    %--------------------------------------------------------------------------
    
    % load images
    images = snLoadInstructions;
    nrImages = size(images,1);
    
    % create textutes
    for i = 1:size(images,1)
        textures{i,1} = Screen('MakeTexture',window,images(i,1).img);
    end
    
    % draw the first texture
    ind = 1;
    secret = 0;
    while (secret==0)
        if(ind<=1)
            ind = 1;
            Screen('DrawTexture', window, textures{ind, 1});
            Screen('flip',window);
            ind = 2;
        end
        
        [secs, keyCode, deltaSecs] = KbWait([],2);
        
        if(keyCode(rightKey))
            
            keyCode(rightKey) = 0;
            
            ind = ind + 1;
            Screen('DrawTexture', window, textures{ind, 1});
            Screen('flip',window);
            if(ind==nrImages)
                ind = ind - 1;
            end
            
        elseif(keyCode(leftKey))
            
            keyCode(leftKey) = 0;
            
            if(ind<=0)
                Screen('DrawTexture', window, textures{1, 1});
                Screen('flip',window);
            else
                Screen('DrawTexture', window, textures{ind-1, 1});
                Screen('flip',window);
                
            end
            ind = ind - 1;
        elseif(keyCode(secretKey))
            secret = 1;
        else
            continue
        end
        
        
    end
    
    
    %--------------------------------------------------------------------------
    % Configure eyetracker
    %--------------------------------------------------------------------------
    
    %%%%% configure eyetracker
    %%% Transition Screen %%%
    Screen('FillRect', window, backgroundColor);
    if trackEye == 1
        line1 = '\n We will now calibrate the eye-tracker. Please alert the experimenter.';
    else
        line1 = '\n We will now move onto the next part of the study. \n Please alert the experimenter.';
    end
    
    
    %Draw all the text in one go
    Screen('TextSize', window, mainSize);
    Screen('TextFont', window, mainFont);
    DrawFormattedText(window, line1,'center', ScreenY*.35, white, [], [], [], 1.5);
    
    Screen('Flip', window);
    
    %Wait for button press
    while KbCheck
    end
    
    FlushEvents('keyDown');
    proceed = 0;
    while proceed == 0
        [keyIsDown, secs, keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(escapeKey)
                ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
            elseif keyCode(expKey)
                proceed = 1;
            end
        end
    end %while proceed
    
    WaitSecs(.1);
    
    if trackEye == 1
        
        % initiates the defaults for the eye tracker on the screen you
        % opened
        el = EyelinkInitDefaults(window);
        
        edfNTrials = 105;
        %create edf file
        edfFileName = ['SN_' num2str(sID)]; % CHANGE TO INCLUDE SUBJ. NUMBER, BUT LESS THAN 8 CHARACTERS. %['SelfControl' num2str(sID)];
        
        % Initialization of the connection with the Eyelink Gazetracker.
        % exit program if this fails.
        if ~EyelinkInit() % Initializes Eyelink and Ethernet system. Returns: 0 if OK, -1 if error
            error('could not init connection to Eyelink')
        end
        
        % check the software version
        [~ , vs] = Eyelink('GetTrackerVersion');
        fprintf('Running experiment on a ''%s'' tracker.\n', vs);
        
        % open file to record data to (which is basically done
        % automatically)
        status = Eyelink('openfile', edfFileName);
        % if something goes wrong with creating the EDF, shut it down.
        if status~=0
            fprintf('Cannot create EDF file ''%s'' ', edfFileName);
            Eyelink('Shutdown');
            Screen('CloseAll');
            return;
        end
        
        
        % SET UP TRACKER CONFIGURATION
        % Setting the proper recording resolution, proper calibration type,
        % as well as the data file content;
        Eyelink('command', 'screen_pixel_coords = %ld %ld %ld %ld', 0, 0, ScreenX, ScreenY);
        Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, ScreenX, ScreenY);
        % set calibration type. (This can also be done in the eye tracking
        % gui at the start of the study, but this makes sure that it's the
        % same for every participant)
        Eyelink('command', 'calibration_type = HV9');
        
        % set EDF file contents using the file_sample_data and
        % file-event_filter commands
        % set link data through link_sample_data and link_event_filter
        Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
        Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
        
        % add "HTARGET" to record possible target data for EyeLink Remote
        % This is done if the version (vs) is >= 4. We don't actually have
        % to worry about this, because we use the headrest (this is for if
        % you use the target sticker and let the head move freely)
        if sscanf(vs(12:end),'%f') >=4
            Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,GAZERES,STATUS,INPUT');
            Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
        else
            Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
            Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
        end
        
        
        % make sure we're still connected.
        if Eyelink('IsConnected') == 0
            fprintf('not connected, clean up\n');
            Eyelink('ShutDown');
            Screen('CloseAll');
            return;
        end
        
        % Calibrate the eye tracker
        % setup the proper calibration foreground and background colors
        % Make sure your background color is different from the foreground
        % and msgfont colors, or else it will look like nothing is being
        % displayed
        el.backgroundcolour = backgroundColor;
        el.foregroundcolour = white;
        el.msgfontcolour  = white;
        el.calibrationtargetcolour = greycol;
        
        % parameters are in frequency, volume, and duration
        % set the second value in each line to 0 to turn off the sound
        el.cal_target_beep=[600, 0, 0.05];
        el.drift_correction_target_beep=[600, 0, 0.05];
        el.calibration_failed_beep=[400, 0, 0.25];
        el.calibration_success_beep=[800, 0, 0.25];
        el.drift_correction_failed_beep=[400, 0, 0.25];
        el.drift_correction_success_beep=[800, 0, 0.25];
        % you must call this function to apply the changes from above
        EyelinkUpdateDefaults(el);
        
        % Hide the mouse cursor
        HideCursor;
        EyelinkDoTrackerSetup(el); % Calibration
        %EyelinkDoDriftCorrection(el); - this is unneccessary to do
        %immediately after calibrating
        
        % Maximize Keyboard priority??
        %Priority(1);
        
    end % of trackEye
    %%%%%
    
    
    
    %--------------------------------------------------------------------------
    % Start Screen
    %--------------------------------------------------------------------------
    
    HideCursor();
    
    DrawFormattedText(window,['Press any key to start the experiment.'],'center','center',textColor);
    Screen('Flip',window);
    KbWait([], 2);
    KbWait([], 1);
    
    
    
    %--------------------------------------------------------------------------
    % Control Task
    %--------------------------------------------------------------------------
    trialNControl0 = 7;
    answerMatControl0 = zeros(7,3);
    
    for trialControl0 = 1:7
        %----------------------------------------------------------------------
        % Block screen
        %----------------------------------------------------------------------
        % trial exchange rate other:self
        erTrialControl0 = expDesignControl0(trialControl0,6);
        % text styles
        Screen('TextFont', window,'Arial');
        Screen('TextSize', window,25);
        Screen('TextStyle', window,1);
        
        % display exchnage rate before the decision
        HideCursor();
        DrawFormattedText(window,'This round has an exchange rate of ','center', midY - 40, textColor);
        DrawFormattedText(window,num2str(erTrialControl0),'center',midY, red);
        % DrawFormattedText(window,'for self versus other.','center',midY, textColor);
        DrawFormattedText(window,'Press any key to make your decision.','center',midY + 40, textColor);
        Screen('Flip',window);
        KbWait([], 2);
        KbWait([], 1);
        
        
        %----------------------------------------------------------------------
        % Trial answer
        %----------------------------------------------------------------------
        ansRectControl = 1;
        question  = ' ';
        
        % use this if you don't want any numbers displayed on the slider
        labelsTopControl = {};
        labelsBottomControl = {};
        
        % set position of the mouse at the beginning of the trial
        midyScale = rectScontrol(ansRectControl,2) + round((rectScontrol(ansRectControl,4)-rectScontrol(ansRectControl,2))/2);
        midxScale = rectScontrol(ansRectControl,1) + round((rectScontrol(ansRectControl,3)-rectScontrol(ansRectControl,1))/2);
        SetMouse(midxScale, midyScale, window, 1);
        
        [positionControl0, RTControl0, answerControl0] = snSlideScaleTrialNoEyeControl(sID,trialControl0,trialNControl0,erTrialControl0,...
            trackEye,...
            window,[' '],...
            rectCcontrol,rectScontrol,rectBcontrol,ansRectControl,...
            labelsTopControl,labelsBottomControl,...
            shiftNumberUpControl, shiftNumberDownControl,...
            'device', 'mouse', ...
            'stepsize', 100,...
            'startposition','center',...
            'range',2,...
            'scalaposition',0.5,...
            'scalacolor',sliderColor,...
            'linelength',5,...
            'framecolorself',frameColorSelfControl,...
            'framecolorother',frameColorOther,...
            'slidercolor',pink,...
            'buttoncolor', pink,...
            'displayposition',1 );
        
        % trial answer data
        answerMatControl0(trialControl0,:) = [positionControl0, RTControl0, answerControl0];
        
        %----------------------------------------------------------------------
        % Display fixation cross (iti)
        %----------------------------------------------------------------------
        Screen('FillRect', window, fixColor  , FixCross');
        Screen('Flip',window);
        WaitSecs(2);
        
    end
    
    
    %--------------------------------------------------------------------------
    % Main Task
    %--------------------------------------------------------------------------
    trialN = size(expDesign,1);
    trialNControl1 = 7;
    
    
    answerMat = zeros(size(expDesign,1),3);
    answerMatControl1 = zeros(7,3);
    
    eyeData = [];
    
    trial = 0;
    for block = 1:1 % change this to 7 for the whole experiment
        
        %----------------------------------------------------------------------
        % No social information trial
        %----------------------------------------------------------------------
        % trial number for the control i.e. block number
        trialControl1 = block;
        
        % control trial exchange rate
        erTrialControl1 = expDesignControl1(trialControl1,6);
        erBlock = expDesignControl1(trialControl1,3);
        % text styles
        Screen('TextFont', window,'Arial');
        Screen('TextSize', window,25);
        Screen('TextStyle', window,1);
        
        % make font bigger at the beggining of the block
        Screen('TextSize', window,30);
        HideCursor();
        DrawFormattedText(window,'You will now enter a new room.','center', midY - 40, textColor);
        DrawFormattedText(window,'Press any key to continue.','center',midY + 40, textColor);
        Screen('Flip',window);
        KbWait([], 2);
        KbWait([], 1);
        
        HideCursor();
        DrawFormattedText(window,'The following room has an average exchange rate of ','center', midY - 40, textColor);
        DrawFormattedText(window,num2str(erBlock),'center',midY, red);
        %DrawFormattedText(window,'for self versus other.','center',midY, textColor);
        DrawFormattedText(window,'Press any key to enter the room.','center',midY + 40, textColor);
        Screen('Flip',window);
        KbWait([], 2);
        KbWait([], 1);
        
        % display fixation cross
        Screen('FillRect', window, fixColor  , FixCross');
        Screen('Flip',window);
        WaitSecs(2);
        Screen('TextSize', window, 25);
        
        % display exchnage rate before the decision
        HideCursor();
        DrawFormattedText(window,'This round has an exchange rate of ','center', midY - 40, textColor);
        DrawFormattedText(window,num2str(erTrialControl1),'center',midY, red);
        %DrawFormattedText(window,'for self versus other.','center',midY, textColor);
        DrawFormattedText(window,'Press any key to make your decision.','center',midY + 40, textColor);
        Screen('Flip',window);
        KbWait([], 2);
        KbWait([], 1);
        Screen('TextSize', window, 18);
        
        % position on the screen of the participant
        ansRect = expDesignControl1(trialControl1,12);
        
        % social information
        rectBtrial = squeeze(rectB(trialControl1,:,:));
        question  = ' ';
        
        % if you don't want labels for the slider
        labelsTop = {};
        labelsBottom = {};
        
        % set position of the mouse at the beginning of the trial
        midyScale = rectS(ansRect,2) + round((rectS(ansRect,4)-rectS(ansRect,2))/2);
        midxScale = rectS(ansRect,1) + round((rectS(ansRect,3)-rectS(ansRect,1))/2);
        SetMouse(midxScale, midyScale, window, 1);
        
        [positionControl1, RTControl1, answerControl1] = snSlideScaleTrialNoEyeNoSocial(sID,trialControl1,trialNControl1,erTrialControl1,...
            trackEye,...
            window,[' '],...
            rectC,rectS,rectBtrial,ansRect,...
            labelsTop,labelsBottom,...
            shiftNumberUp, shiftNumberDown,...
            'device', 'mouse', ...
            'stepsize', 100,...
            'startposition','center',...
            'range',2,...
            'scalaposition',0.5,...
            'scalacolor',sliderColor,...
            'linelength',5,...
            'framecolorself',frameColorSelf,...
            'framecolorother',frameColorOther,...
            'slidercolor',pink,...
            'buttoncolor', pink,...
            'displayposition',1 );
        if trackEye == 1
            eyeDataChoice  = [];
        end
        
        %----------------------------------------------------------------------
        % Social information trials
        %----------------------------------------------------------------------
        
        for trial_block = 1:20
            % trial number for the whole experiment
            trial = trial + 1;
            % trial exchange rate
            erTrial = expDesign(trial,6);
            
            % text styles
            Screen('TextFont', window,'Arial');
            Screen('TextSize', window,25);
            Screen('TextStyle', window,1);
            
            % display exchnage rate before the decision
            HideCursor();
            DrawFormattedText(window,'This round has an exchange rate of ','center', midY - 40, textColor);
            DrawFormattedText(window,num2str(erTrial),'center',midY, red);
            %DrawFormattedText(window,'for self versus other.','center',midY, textColor);
            DrawFormattedText(window,'Press any key to make your decision.','center',midY + 40, textColor);
            Screen('Flip',window);
            KbWait([], 2);
            KbWait([], 1);
            Screen('TextSize', window, 18);
            
            % position on the screen of the participant
            ansRect = expDesign(trial,12);
            
            % social information
            rectBtrial = squeeze(rectB(trial,:,:));
            question  = ' ';
            
            % if you don't want labels for the slider
            labelsTop = {};
            labelsBottom = {};
            
            % get answer when social information is present
            if trackEye == 1
                % set position of the mouse at the beginning of the trial
                midyScale = rectS(ansRect,2) + round((rectS(ansRect,4)-rectS(ansRect,2))/2);
                midxScale = rectS(ansRect,1) + round((rectS(ansRect,3)-rectS(ansRect,1))/2);
                SetMouse(midxScale, midyScale, window, 1);
                
                [position, RT, answer, eyeDataChoice] = snSlideScaleTrialEye(sID,trial,trialN,erTrial,...
                    trackEye,el,...
                    window,[' '],...
                    rectAOI,rectC,rectS,rectBtrial,ansRect,expSocialInfo,...
                    labelsTop,labelsBottom,...
                    shiftNumberUp, shiftNumberDown,...
                    'device', 'mouse', ...
                    'stepsize', 100,...
                    'startposition','center',...
                    'range',2,...
                    'scalaposition',0.5,...
                    'scalacolor',sliderColor,...
                    'linelength',5,...
                    'framecolorself',frameColorSelf,...
                    'framecolorother',frameColorOther,...
                    'slidercolor',pink,...
                    'buttoncolor', pink,...
                    'displayposition',1 );
            else
                % set position of the mouse at the beginning of the trial
                midyScale = rectS(ansRect,2) + round((rectS(ansRect,4)-rectS(ansRect,2))/2);
                midxScale = rectS(ansRect,1) + round((rectS(ansRect,3)-rectS(ansRect,1))/2);
                SetMouse(midxScale, midyScale, window, 1);
                
                [position, RT, answer] = snSlideScaleTrialNoEye(sID,trial,trialN,erTrial,...
                    trackEye,...
                    window,[' '],...
                    rectC,rectS,rectBtrial,ansRect,expSocialInfo,...
                    labelsTop,labelsBottom,...
                    shiftNumberUp, shiftNumberDown,...
                    'device', 'mouse', ...
                    'stepsize', 100,...
                    'startposition','center',...
                    'range',2,...
                    'scalaposition',0.5,...
                    'scalacolor',sliderColor,...
                    'linelength',5,...
                    'framecolorself',frameColorSelf,...
                    'framecolorother',frameColorOther,...
                    'slidercolor',pink,...
                    'buttoncolor', pink,...
                    'displayposition',1 );
            end
            
            
            % answers for control trials with no social information
            answerMatControl1(trialControl1,:) = [positionControl1, RTControl1, answerControl1];
            % trial answer data
            answerMat(trial,:) = [position, RT, answer];
            
            if trackEye == 1
                eyeData = [eyeData; eyeDataChoice];
            end
            %----------------------------------------------------------------------
            % Display fixation cross (iti)
            %----------------------------------------------------------------------
            
            if trackEye == 0
                Screen('FillRect', window, fixColor  , FixCross');
                Screen('Flip',window);
                WaitSecs(2);
            else
                %%%%%%eyetracking%%%%%%%%%
                Eyelink('command', 'record_status_message "FIXCROSS TRIAL %d/%d"', trial, trialN);
                
                % start recording eye position (preceded by a short pause so that
                % the tracker can finish the mode transition)
                % The paramerters for the 'StartRecording' call controls the
                % file_samples, file_events, link_samples, link_events availability
                Eyelink('Command', 'set_idle_mode');
                WaitSecs(0.05);
                Eyelink('StartRecording');
                % record a few samples before we actually start displaying
                % otherwise you may lose a few msec of data
                WaitSecs(0.1);
                eye_used = Eyelink('eyeavailable'); % get the eye that's tracked
                
                
                %             % used for syncing time, This will print "synctime_part1" into
                %             % the EDF at this timepoint. This is useful for keeping track
                %             % in the edf of when a trial starts, and what part of the study
                %             % it belongs to if you have several parts.
                %             Eyelink('Message', 'SYNCTIME_part1');
                %             % This is just telling us that the trial is valid (useful for
                %             % if you recallibrate during a trial, in which case this will
                %             % later be switched to 0 so you know to throw the trial out)
                %             Eyelink('Message', '!V TRIAL_VAR VALID_TRIAL %d', 1);
                %
                %             eye_used = Eyelink('eyeavailable'); % get eye that's tracked
                %
                %             % Set up the two ROIs. The !V is asking for gaze/velocity
                %             % information, IAREA RECTANGLE is the type of roi (it's a
                %             % rectangle... but you can also change it to be IAREA ELLIPSE
                %             % for circles or IAREA FREEHAND for an irregular shape.)
                %             % The following "%d"s correspond to the following (for both
                %             % rectangle and ellipse):
                %             % 1: id #
                %             % 2 & 3: top left (x,y)
                %             % 4 & 5: bottom right (x,y)
                %             % For freehand, the first one is still id #, the following are
                %             % x,y coordinates for each outer portion of the ROI (only x,y pairs
                %             % have a comma between them).
                %             % The final %s corresponds to the label string you give your
                %             % ROI. The examples below are two ROIs for the left and right
                %             % side of the screen.
                %             Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 1, midX-50, midY-50, midX+50, midY+50, 'cross1');
                
                % PUT CODE FOR DRAWING THE FIXATION CROSS HERE
                Screen('FillRect', window, fixColor  , FixCross');
                %flip to screen
                [~, startTime, ~, ~] = Screen('Flip', window, 1);
                
                fixDur = 2;
                % if you want people to fixate the cross for a specific period
                % of time, here you go.
                while GetSecs - startTime <= fixDur % fixDur is how long you want them to fixate before moving on
                    % Check if there's a new sample
                    if Eyelink('NewFloatSampleAvailable') > 0
                        % get the sample in the form of an event structure
                        evt = Eyelink('NewestFloatSample');
                        if eye_used ~= -1 % do we know which eye to use yet?
                            % if we do, get current gaze position from sample
                            % x-coordinate
                            eyeX = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                            % y-coordinate
                            eyeY = evt.gy(eye_used+1);
                            % pupil area - not used in standard eye tracking
                            % really, but great if you're looking at pupil
                            % dilation or making sure they're not blinking
                            a = evt.pa(eye_used+1);
                            
                            % do we have valid data and is the pupil visible?
                            if eyeX ~= el.MISSING_DATA && eyeY ~= el.MISSING_DATA && a > 0
                                distFromFix = sqrt((eyeX - midX)^2 + (eyeY - midY)^2);
                            else
                                distFromFix = 99999; % if no eye is present,do not advance trial
                            end
                        end
                        
                        if distFromFix > fixThresh
                            startTime = GetSecs; % Do not advance the trial, and reset the counter
                        end
                        
                        % During this time, add in the option to recalibrate
                        FlushEvents('keydown');
                        [keyIsDown, ~, keyCode] = KbCheck(-1);
                        if keyIsDown
                            if keyCode(KbName('c'))
                                % Change this label to be 0, so you know the
                                % trial actually wasn't valid
                                Eyelink('Message', '!V TRIAL_VAR VALID_TRIAL %d', 0);
                                Eyelink('StopRecording');
                                EyelinkDoTrackerSetup(el);
                                Eyelink('StartRecording');
                                Eyelink('Message', '!V TRIAL_VAR VALID_TRIAL %d', 1);
                            end
                        end
                    end
                end
                %%%%%%%%%%%%%%%%%%
            end
            
            
        end
        
    end
    
    
    
    %%%%%%eyetracking%%%%%%%%%
    if trackEye == 1
        Eyelink('StopRecording');
    end
    
    % close eyetracker
    if trackEye == 1
        Eyelink('CloseFile');
        Eyelink('ReceiveFile');
        Eyelink('ShutDown');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % end experiment
    HideCursor();
    Screen('TextSize', window,25);
    DrawFormattedText(window,'The experiment has ended.','center', midY - 40, textColor);
    DrawFormattedText(window,'You will receive the payment in about one week when we finish collecting the data from other participants.','center',midY, red);
    %DrawFormattedText(window,'for self versus other.','center',midY, textColor);
    DrawFormattedText(window,'Press any key to end the experiment.','center',midY + 40, textColor);
    Screen('Flip',window);
    KbWait([], 2);
    KbWait([], 1);
    
    %--------------------------------------------------------------------------
    % Save data
    %--------------------------------------------------------------------------
    answerMatExp = [answerMatControl0; answerMatControl1; answerMat];
    expDesignExp = [expDesignControl0; expDesignControl1; expDesign];
    expSocialInfoExp = [expNoSocialInfoControl0; expNoSocialInfoControl1; 10*expSocialInfo];
    
    if ~exist('completeData', 'dir')
        mkdir('completeData')
    end
    
    sVec = ones(size(answerMatExp,1),1).*sID;
    dataFile = fullfile('completeData',[datestr(now,'mm-dd-yyyy'),'-S',num2str(sID),'-BEH','.mat']);
    save(dataFile,'expDesignExp','expSocialInfoExp','answerMatExp','sVec');
    
    dataFileInfo = fullfile('completeData',[datestr(now,'mm-dd-yyyy'),'-S',num2str(sID),'-PAY','.mat']);
    save(dataFileInfo, 'sesInfo');
    
    %%%%%%eyetracking%%%%%%%%%
    if trackEye ==1
        if ~exist('completeDataEye', 'dir')
            mkdir('completeDataEye')
        end
        
        if ~exist('completeDataEyeMat', 'dir')
            mkdir('completeDataEyeMat')
        end
        
        addpath('./edfImport-master/');
        
        % save eyetracking data
        eyeTrials = edfImport(['SN_',num2str(sID)]);
        eyeTrialsEvents = edfExtractInterestingEvents(eyeTrials);
        eyeTrialsVar = edfExtractVariables(eyeTrials);
        
        dataFileEye = fullfile('completeDataEye',[datestr(now,'mm-dd-yyyy'),'-S',num2str(sID),'-EYE','.mat']);
        save(dataFileEye,'eyeTrials','eyeTrialsEvents','eyeTrialsVar','sVec');
        
        dataFileEyeMat = fullfile('completeDataEyeMat',[datestr(now,'mm-dd-yyyy'),'-S',num2str(sID),'-EYE-MAT','.mat']);
        save(dataFileEyeMat,'eyeData','sVec');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %--------------------------------------------------------------------------
    % Calculate points earned
    %--------------------------------------------------------------------------
    
    % pick one random trial for payment
    
    % display payment
    
    % close screen
    fclose('all');
    Screen('CloseAll');
    
catch err  %quit out if the code encounters an error
    disp('There is an ERROR!');
    matlabfile = ['matlab_',datestr(now,'mm-dd-yyyy'), '-S',num2str(sID), '.mat'];
    save(matlabfile);
    
    ListenChar(0); %restore normal keyboard use
    
    sca
    fclose('all');
    if trackEye == 1
        Eyelink('CloseFile');
        Eyelink('ReceiveFile');
        Eyelink('ShutDown');
    end
    ShowCursor;
    Screen('CloseAll')
    rethrow(err);
end
