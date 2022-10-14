function [position, RT, answer, eyeDataChoice] = snSlideScaleTrialEye(sID,trial, trialN, erTrial, trackEye, el, screenPointer, question, rectAOI, rectC, rectS, rectB, ansRect, expSocialInfo, anchorsTop, anchorsBottom, shiftNumberUp, shiftNumberDown, varargin)
%
% SLIDESCALE This funtion draws a slide scale on a PSYCHTOOLOX 3 screen and returns the
% position of the slider spaced between -100 and 100 as well as the rection time and if an answer was given.
%
%   Usage: [position, secs] = slideScale(ScreenPointer, question, center, rect, endPoints, varargin)
%   Mandatory input:
%    ScreenPointer  -> Pointer to the window.
%    question       -> Text string containing the question.
%    rect           -> Double contatining the screen size.
%                      Obtained with [myScreen, rect] = Screen('OpenWindow', 0);
%    anchors        -> Cell containg the two or three text strings of the left (, middle) and right
%                      end of the scale. Exampe: anchors = {'left', 'middle', 'right'}
%
%   Varargin:
%    'linelength'     -> An integer specifying the lengths of the ticks in
%                        pixels. The default is 10.
%    'width'          -> An integer specifying the width of the scale line in
%                        pixels. The default is 3.
%    'range'          -> An integer specifying the type of range. If 1,
%                        then the range is from -100 to 100. If 2, then the
%                        range is from 0 to 100. Default is 1.
%    'startposition'  -> Choose 'right', 'left' or 'center' start position.
%                        Default is center.
%    'scalalength'    -> Double value between 0 and 1 for the length of the
%                        scale. The default is 0.9.
%    'scalaposition'  -> Double value between 0 and 1 for the position of the
%                        scale. 0 is top and 1 is bottom. Default is 0.8.
%    'device'         -> A string specifying the response device. Either 'mouse'
%                        or 'keyboard'. The default is 'mouse'.
%    'responsekeys'   -> Vector containing keyCodes of the keys from the keyboard to log the
%                        response and move the slider to the right and left.
%                        The default is [KbName('return') KbName('LeftArrow') KbName('RightArrow')].
%    'stepSize'       -> An integer specifying the number of pixel the
%                        slider moves with each step. Default is 1.
%    'slidercolor'    -> Vector for the color value of the slider [r g b]
%                        from 0 to 255. The default is red [255 0 0].
%    'scalacolor'     -> Vector for the color value of the scale [r g b]
%                        from 0 to 255.The default is black [0 0 0].
%    'aborttime'      -> Double specifying the time in seconds after which
%                        the function should be aborted. In this case no
%                        answer is saved. The default is Inf.
%    'image'          -> An image saved in a uint8 matrix. Use
%                        imread('image.png') to load an image file.
%    'displayposition' -> If true, the position of the slider is displayed.
%                        The default is false.
%
%   Output:
%    'position'      -> Deviation from zero in percentage,
%                       with -100 <= position <= 100 to indicate left-sided
%                       and right-sided deviation.
%    'RT'            -> Reaction time in milliseconds.
%    'answer'        -> If 0, no answer has been given. Otherwise this
%                       variable is 1.
%
%   Author: Joern Alexander Quent
%   e-mail: Alex.Quent@mrc-cbu.cam.ac.uk
%% Parse input arguments
% Default values
lineLength    = 10;
width         = 5;
scalaPosition = 0.5; % 0.8;
sliderColor   = [1 0 0];
scaleColor    = [0 0 0];
device        = 'mouse';
aborttime     = Inf;
responseKeys  = [KbName('return') KbName('LeftArrow') KbName('RightArrow')];
GetMouseIndices;
drawImage     = 0;
startPosition = 'center';
displayPos    = true;
rangeType     = 1;
stepSize      = 1;
framecolorself = [1 0 0];
framecolorother = [1 1 1];


i = 1;
while(i<=length(varargin))
    switch lower(varargin{i})
        case 'linelength'
            i             = i + 1;
            lineLength    = varargin{i};
            i             = i + 1;
        case 'width'
            i             = i + 1;
            width         = varargin{i};
            i             = i + 1;
        case 'range'
            i             = i + 1;
            rangeType     = varargin{i};
            i             = i + 1;
        case 'startposition'
            i             = i + 1;
            startPosition = varargin{i};
            i             = i + 1;
        case 'scalaposition'
            i             = i + 1;
            scalaPosition = varargin{i};
            i             = i + 1;
        case 'device'
            i             = i + 1;
            device        = varargin{i};
            i             = i + 1;
        case 'responsekeys'
            i             = i + 1;
            responseKeys  = varargin{i};
            i             = i + 1;
        case 'stepsize'
            i             = i + 1;
            stepSize      = varargin{i};
            i             = i + 1;
        case 'slidercolor'
            i             = i + 1;
            sliderColor   = varargin{i};
            i             = i + 1;
        case 'buttoncolor'
            i             = i + 1;
            buttonColor   = varargin{i};
            i             = i + 1;
        case 'framecolorself'
            i             = i + 1;
            framecolorself   = varargin{i};
            i             = i + 1;
        case 'framecolorother'
            i             = i + 1;
            framecolorother   = varargin{i};
            i             = i + 1;
        case 'scalacolor'
            i             = i + 1;
            scaleColor    = varargin{i};
            i             = i + 1;
        case 'aborttime'
            i             = i + 1;
            aborttime     = varargin{i};
            i             = i + 1;
        case 'image'
            i             = i + 1;
            image         = varargin{i};
            i             = i + 1;
            imageSize     = size(image);
            stimuli       = Screen('MakeTexture', screenPointer, image);
            drawImage     = 1;
        case 'displayposition'
            i             = i + 1;
            displayPos    = varargin{i};
            i             = i + 1;
    end
end

% Sets the default key depending on choosen device
if strcmp(device, 'mouse')
    mouseButton   = 1; % X mouse button
end

%% Checking number of screens and parsing size of the global screen
screens       = Screen('Screens');
if length(screens) > 1 % Checks for the number of screens
    screenNum        = 1;
else
    screenNum        = 0;
end

%% Coordinates of scale lines and text bounds
% tick marks
xScaleLength = rectS(ansRect,3)-rectS(ansRect,1);
midxScale = rectS(ansRect,1) + xScaleLength/2;


if strcmp(startPosition, 'right')
    x = rectS(ansRect,1);
elseif strcmp(startPosition, 'center')
    x = midxScale;
elseif strcmp(startPosition, 'left')
    x = rectS(ansRect,3);
else
    error('Only right, center and left are possible start positions');
end

%SetMouse(round(x), rectS(ansRect,2) + round((rectS(ansRect,4)-rectS(ansRect,2))/2), screenPointer, 1);
% added two more tick marks :)
%midTick    = [midxScale, rectS(ansRect,2) - lineLength, midxScale, rectS(ansRect,4) + lineLength];
leftTick   = [rectS(ansRect,1), rectS(ansRect,2) - lineLength, rectS(ansRect,1), rectS(ansRect,4) + lineLength];
rightTick  = [rectS(ansRect,3), rectS(ansRect,2) - lineLength, rectS(ansRect,3), rectS(ansRect,4) + lineLength];
%leftmidTick = [midxScale-xScaleLength/4, rectS(ansRect,2) - lineLength, midxScale-xScaleLength/4, rectS(ansRect,4) + lineLength];
%rightmidTick = [midxScale+xScaleLength/4, rectS(ansRect,2) - lineLength, midxScale+xScaleLength/4, rectS(ansRect,4) + lineLength];


if length(anchorsTop) == 2
    textBounds = [Screen('TextBounds', screenPointer, sprintf(anchorsTop{1}));
        Screen('TextBounds', screenPointer, sprintf(anchorsTop{2}))];
elseif length(anchorsTop) == 5
    textBounds = [Screen('TextBounds', screenPointer, sprintf(anchorsTop{1}));
        Screen('TextBounds', screenPointer, sprintf(anchorsTop{2}));
        Screen('TextBounds', screenPointer, sprintf(anchorsTop{3}));
        Screen('TextBounds', screenPointer, sprintf(anchorsTop{4}));
        Screen('TextBounds', screenPointer, sprintf(anchorsTop{5}))];
else
    % do nothing
end

% need to change some things if image used
if drawImage == 1
    rectImage  = [midxScale - imageSize(2)/2 rectC(ansRect,4)*(scalaPosition - 0.2) - imageSize(1) midxScale + imageSize(2)/2 rectC(ansRect,4)*(scalaPosition - 0.2)];
    if rectC(ansRect,4)*(scalaPosition - 0.2) - imageSize(1) < 0
        error('The height of the image is too large. Either lower your scale or use the smaller image.');
    end
end

% Calculate the range of the scale, which will be need to calculate the position
scaleRange        = round(rectS(ansRect,1)):round(rectS(ansRect,3)); % Calculates the range of the scale
scaleRangeShifted = round((scaleRange)-mean(scaleRange));            % Shift the range of scale so it is symmetrical around zero

%% set up eyetracker
%%%%%%eyetracking%%%%%%
if trackEye == 1
    
    Eyelink('command', 'record_status_message "CHOICE TRIAL %d/%d"', trial, trialN);
    
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
    
    
    % used for syncing time, This will print "synctime_part1" into
    % the EDF at this timepoint. This is useful for keeping track
    % in the edf of when a trial starts, and what part of the study
    % it belongs to if you have several parts.
    Eyelink('Message', 'SYNCTIME_exp');
    % This is just telling us that the trial is valid (useful for
    % if you recallibrate during a trial, in which case this will
    % later be switched to 0 so you know to throw the trial out)
    Eyelink('Message', '!V TRIAL_VAR VALID_TRIAL %d', 1);
    
    eye_used = Eyelink('eyeavailable'); % get eye that's tracked
    
    % Set up the two ROIs. The !V is asking for gaze/velocity
    % information, IAREA RECTANGLE is the type of roi (it's a
    % rectangle... but you can also change it to be IAREA ELLIPSE
    % for circles or IAREA FREEHAND for an irregular shape.)
    % The following "%d"s correspond to the following (for both
    % rectangle and ellipse):
    % 1: id #
    % 2 & 3: top left (x,y)
    % 4 & 5: bottom right (x,y)
    % For freehand, the first one is still id #, the following are
    % x,y coordinates for each outer portion of the ROI (only x,y pairs
    % have a comma between them).
    % The final %s corresponds to the label string you give your
    % ROI. The examples below are two ROIs for the left and right
    % side of the screen.
    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 1, rectAOI(1,1),rectAOI(1,2),rectAOI(1,3),rectAOI(1,4),'up-left');
    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 2, rectAOI(2,1),rectAOI(2,2),rectAOI(2,3),rectAOI(2,4),'up-middle');
    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 3, rectAOI(3,1),rectAOI(3,2),rectAOI(3,3),rectAOI(3,4),'up-right');
    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 4, rectAOI(4,1),rectAOI(4,2),rectAOI(4,3),rectAOI(4,4),'mid-left');
    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 5, rectAOI(5,1),rectAOI(5,2),rectAOI(5,3),rectAOI(5,4),'mid-middle');
    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 6, rectAOI(6,1),rectAOI(6,2),rectAOI(6,3),rectAOI(6,4),'mid-right');
    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 7, rectAOI(7,1),rectAOI(7,2),rectAOI(7,3),rectAOI(7,4),'down-left');
    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 8, rectAOI(8,1),rectAOI(8,2),rectAOI(8,3),rectAOI(8,4),'down-middle');
    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 9, rectAOI(9,1),rectAOI(9,2),rectAOI(9,3),rectAOI(9,4),'down-right');
    
end
%%%%%%%%%%%%%
%% Loop for scale loop
%%%%%%eyetracking%%%%%%%
eyeDataChoice = [];
lookAOI = -1; % set default
prevlookAOI = -1; % set default
fixEnd = 0; % set default
fixStart = -1;
trialStart = GetSecs();
%%%%%%%%%%%%%%%%%%%%%%%%
t0     = GetSecs;
answer = 0;
while answer == 0
   
    
    % Parse user input for x location
    if strcmp(device, 'mouse')
        [x,~,buttons,~,~,~] = GetMouse(screenPointer, 1);
    elseif strcmp(device, 'keyboard')
        [~, ~, keyCode] = KbCheck;
        if keyCode(responseKeys(2)) == 1
            x = x - stepSize; % Goes stepSize pixel to the left
        elseif keyCode(responseKeys(3)) == 1
            x = x + stepSize; % Goes stepSize pixel to the right
        end
    else
        error('Unknown device');
    end
    
    % Stop at upper and lower bound
    if x > rectS(ansRect,3)
        x = rectS(ansRect,3);
    elseif x < rectS(ansRect,1)
        x = rectS(ansRect,1);
    end
    
    % Draw image if provided
    if drawImage == 1
        Screen('DrawTexture', screenPointer, stimuli,[] , rectImage, 0);
    end
    
    % Drawing the question as text
    DrawFormattedText(screenPointer, question, 'center',rectS(ansRect,2)+ 80);
    
    % Drawing the anchors of the scale as text
    if length(anchorsTop) == 2
        % Only left and right anchors
        DrawFormattedText(screenPointer, anchorsTop{1}, leftTick(1, 1) - textBounds(1, 3)/2,  rectS(ansRect,2)-40, [],[],[],[],[],[],[]); % Left point
        DrawFormattedText(screenPointer, anchorsTop{2}, rightTick(1, 1) - textBounds(2, 3)/2,  rectS(ansRect,2)-40, [],[],[],[],[],[],[]); % Right point
    elseif length(anchorsTop) == 5
        % Left, middle and right anchors
        DrawFormattedText(screenPointer, anchorsTop{1}, leftTick(1, 1) - textBounds(1, 3)/2,  rectS(ansRect,2)-40, [],[],[],[],[],[],[]); % Left point
        DrawFormattedText(screenPointer, anchorsTop{2}, leftmidTick(1, 1) - textBounds(2, 3)/2,  rectS(ansRect,2)-40, [],[],[],[],[],[],[]); % Left mid point
        DrawFormattedText(screenPointer, anchorsTop{3}, midTick(1, 1) - textBounds(3, 3)/2, rectS(ansRect,2)-40, [],[],[],[],[],[],[]); % Middle point
        DrawFormattedText(screenPointer, anchorsTop{4}, rightmidTick(1, 1) - textBounds(4, 3)/2, rectS(ansRect,2)-40, [],[],[],[],[],[],[]); % Right mid point
        DrawFormattedText(screenPointer, anchorsTop{5}, rightTick(1, 1) - textBounds(5, 3)/2, rectS(ansRect,2)-40, [],[],[],[],[],[],[]); % Right point
        % added two more text labels :)
    else
        % do nothing
    end
    
    % added top text labels :)
    if length(anchorsBottom) == 2
        % Only left and right anchors
        DrawFormattedText(screenPointer, anchorsBottom{1}, leftTick(1, 1) - textBounds(1, 3)/2,  rectS(ansRect,4)+20, [],[],[],[],[],[],[]); % Left point
        DrawFormattedText(screenPointer, anchorsBottom{2}, rightTick(1, 1) - textBounds(2, 3)/2,  rectS(ansRect,4)+20, [],[],[],[],[],[],[]); % Right point
    elseif length(anchorsBottom) == 5
        % Left, middle and right anchors
        DrawFormattedText(screenPointer, anchorsBottom{1}, leftTick(1, 1) - textBounds(1, 3)/2, rectS(ansRect,4)+20, [],[],[],[],[],[],[]); % Left point
        DrawFormattedText(screenPointer, anchorsBottom{2}, leftmidTick(1, 1) - textBounds(2, 3)/2, rectS(ansRect,4)+20, [],[],[],[],[],[],[]); % Left mid point
        DrawFormattedText(screenPointer, anchorsBottom{3}, midTick(1, 1) - textBounds(3, 3)/2, rectS(ansRect,4)+20, [],[],[],[],[],[],[]); % Middle point
        DrawFormattedText(screenPointer, anchorsBottom{4}, rightmidTick(1, 1) - textBounds(4, 3)/2, rectS(ansRect,4)+20, [],[],[],[],[],[],[]); % Right mid point
        DrawFormattedText(screenPointer, anchorsBottom{5}, rightTick(1, 1) - textBounds(5, 3)/2, rectS(ansRect,4)+20, [],[],[],[],[],[],[]); % Right point
        % added two more text labels :)
    else
        % do nothing
    end
    
    % Drawing the scale
    %Screen('DrawLine', screenPointer, scaleColor, midTick(1), midTick(2), midTick(3), midTick(4), width);         % Mid tick
    Screen('DrawLine', screenPointer, scaleColor, leftTick(1), leftTick(2), leftTick(3), leftTick(4), width);     % Left tick
    Screen('DrawLine', screenPointer, scaleColor, rightTick(1), rightTick(2), rightTick(3), rightTick(4), width); % Right tick
    %Screen('DrawLine', screenPointer, scaleColor, leftmidTick(1), leftmidTick(2), leftmidTick(3), leftmidTick(4), width-1);     % Left mid tick
    %Screen('DrawLine', screenPointer, scaleColor, rightmidTick(1), rightmidTick(2), rightmidTick(3), rightmidTick(4), width-1); % Right mid tick
    
    % added scale rectangle for self :)
    Screen('FillRect', screenPointer, scaleColor, rectS(ansRect,:));
    % added frame color for self :)
    Screen('FrameRect',screenPointer, framecolorself, rectC(ansRect,:), 3);
    % added scales for others :)
    formatSpecOther = '%.1f';
    formatSpecSelf = '%.1f';
    k = 0;
    for j = 1:size(rectC,1)
        if j~=ansRect
            k = k + 1;
            Screen('FillRect', screenPointer, scaleColor, rectS(j,:));
            % added slider position for others :)
            Screen('FillRect', screenPointer, buttonColor, rectB(j,:));
            % added frame color for self :)
            Screen('FrameRect',screenPointer, framecolorother, rectC(j,:), 1);
            % added numbers for self give rate
            DrawFormattedText(screenPointer, num2str(expSocialInfo(trial,k),formatSpecSelf), rectB(j,1) - 10, rectS(j,4) + shiftNumberUp, [1 0 0]);
            % added numbers for other received rate
            DrawFormattedText(screenPointer, num2str(expSocialInfo(trial,k)*erTrial,formatSpecOther), rectB(j,1) - 10, rectS(j,2) - shiftNumberDown, [0 1 0]);
        end
    end
    
    % The slider
    Screen('DrawLine', screenPointer, sliderColor, x, rectS(ansRect,2) - lineLength, x, rectS(ansRect,4) + lineLength, width);
    
    % Caculates position
    if rangeType == 1
        position = round((x)-mean(scaleRange));           % Calculates the deviation from the center
        position = (position/max(scaleRangeShifted))*100; % Converts the value to percentage
    elseif rangeType == 2
        position = round((x)-min(scaleRange));                       % Calculates the deviation from 0.
        position = (position/(max(scaleRange)-min(scaleRange)))*100; % Converts the value to percentage
    end
    
   
    % Display position
    if displayPos
        % self points - bottom of slider
        DrawFormattedText(screenPointer, num2str(position,formatSpecSelf), x - 10, rectS(ansRect,4) + shiftNumberUp, [1 0 0]);
        % other points - top of slider
        DrawFormattedText(screenPointer, num2str(position*erTrial,formatSpecOther), x - 10, rectS(ansRect,2) - shiftNumberDown, [0 1 0]);
    end
    
    % Flip screen
    if trackEye == 0
        Screen('Flip', screenPointer);
    elseif trackEye == 1
        % [~, trialOnset, ~, ~, ~] = Screen('Flip', screenPointer);
        Screen('Flip', screenPointer);
        trialOnset = trialStart;
    end
    
    
    %%%%%%eyetracking%%%%%%
    if trackEye == 1
        % Check recording status
        err = Eyelink('CheckRecording');

        if err ~= 0
            error('checkrecording problem, status: %d', err);
        end

        % Check for new sample
        status = Eyelink('NewFloatSampleAvailable');
        if status >= 0
            evt = Eyelink('NewestFloatSample');
            % if we do, get current gaze position from sample
            eyeX = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
            eyeY = evt.gy(eye_used+1);
            eyetime = GetSecs();

            % Make sure that the data you're recording is even
            % valid
            if eyeX ~= el.MISSING_DATA && eyeY ~= el.MISSING_DATA && evt.pa(eye_used+1)>0

                % See which ROI they're looking at - if they're
                % outside of both roi's, it's counted as a -1
                if eyeY >= rectAOI(1,2) && eyeY <= rectAOI(1,4)
                    if eyeX >= rectAOI(1,1) && eyeX <= rectAOI(1,3)
                        lookAOI = 1;
                    elseif eyeX >= rectAOI(2,1) && eyeX <= rectAOI(2,3)
                        lookAOI = 2;
                    elseif eyeX >= rectAOI(3,1) && eyeX <= rectAOI(4,3)
                        lookAOI = 3;
                    end
                elseif eyeY >= rectAOI(2,2) && eyeY <= rectAOI(2,4)
                    if eyeX >= rectAOI(4,1) && eyeX <= rectAOI(4,3)
                        lookAOI = 4;
                    elseif eyeX >= rectAOI(5,1) && eyeX <= rectAOI(5,3)
                        lookAOI = 5;
                    elseif eyeX >= rectAOI(6,1) && eyeX <= rectAOI(6,3)
                        lookAOI = 6;
                    end
                elseif eyeY >= rectAOI(3,2) && eyeY <= rectAOI(3,4)
                    if eyeX >= rectAOI(7,1) && eyeX <= rectAOI(7,3)
                        lookAOI = 7;
                    elseif eyeX >= rectAOI(8,1) && eyeX <= rectAOI(8,3)
                        lookAOI = 8;
                    elseif eyeX >= rectAOI(9,1) && eyeX <= rectAOI(9,3)
                        lookAOI = 9;
                    end
                end

                % Making this independent of whether
                % the eye was within an roi helps eliminate
                % blinks
                if lookAOI >= 0
                    if lookAOI ~= prevlookAOI
                        newFixStart = eyetime - trialOnset; % finds when the new dwell started
                        if prevlookAOI == -1
                            fixStart = eyetime - trialOnset; %like a default
                        end
                    else
                        fixStart = newFixStart; % keeps the same fix start throughout the dwell
                        fixEnd = eyetime - trialOnset; %updates every time, until they change rois
                    end
                end

                % If they have completed the dwell, aka changed
                % rois, then write down the previous fixation
                % information into your own file. This is so that
                % you have all your information in two places (the
                % EDF and your matlab output). Hopefully you'll
                % only need one.
                if lookAOI ~= prevlookAOI && fixEnd ~= 0 && fixStart ~= -1

                    % Write out the eye data to a file as it's
                    % happening, but only after a dwell has been
                    % completed  - also it says
                    % "prevlookTop" here because we want
                    % what they were just looking at, not
                    % the roi they switched to

    %                 fprintf(eyeTrackDataFile, eyeLabel, ...
    %                     'c','1',num2str(sID), num2str(trial), num2str(prevlookLeft), num2str(fixStart), num2str(fixEnd));
                    eyeDataChoice = [eyeDataChoice; sID, trial, prevlookAOI, fixStart, fixEnd];

                end

                % update the variables
                prevlookAOI = lookAOI;

            end
        end
    end
    %%%%%%%%%%%%%%%
    
    
    % Check if answer has been given
    if strcmp(device, 'mouse')
        secs = GetSecs;
        if buttons(mouseButton) == 1
            answer = 1;
            %%%%%%eyetracking%%%%%%%
            if trackEye == 1
                Eyelink('Message', 'choiceMade');
                % If they made their choice while
                % staring at an ROI, put down RT
                % instead of "fixend" - also it says
                % "prevLookLeft" here because we want
                % what they were just looking at, not
                % the roi they switched to
                if status >= 0 % status is whether or not there's a new sample. Only do this if there's a new sample
%                     fprintf(eyeTrackDataFile, eyeLabel, ...
%                         'c','1',num2str(sID), num2str(trial), num2str(prevlookLeft), num2str(fixStart), num2str(fixEnd));
                     eyeDataChoice = [eyeDataChoice; sID, trial, prevlookAOI, fixStart, fixEnd];
                end
            end %if eyetracking
            %%%%%%%%%%%%%%%%%%%%%%%
        end
    elseif strcmp(device, 'keyboard')
        [~, secs, keyCode] = KbCheck;
        if keyCode(responseKeys(1)) == 1
            answer = 1;
            %%%%%%eyetracking%%%%%%%
            if trackEye == 1
                Eyelink('Message', 'choiceMade');
                % If they made their choice while
                % staring at an ROI, put down RT
                % instead of "fixend" - also it says
                % "prevLookLeft" here because we want
                % what they were just looking at, not
                % the roi they switched to
                if status >= 0 % status is whether or not there's a new sample. Only do this if there's a new sample
%                     fprintf(eyeTrackDataFile, eyeLabel, ...
%                         'c','1',num2str(sID), num2str(trial), num2str(prevlookLeft), num2str(fixStart), num2str(fixEnd));
                     eyeDataChoice = [eyeDataChoice; sID, trial, prevlookAOI, fixStart, fixEnd];
                end
            end %if eyetracking
            %%%%%%%%%%%%%%%%%%%%%%%
        end
        %%%%%%eyetracking%%%%%%%
    elseif(keyCode(escapeKey))
        if trackEye == 1
            Eyelink('CloseFile');
            Eyelink('ReceiveFile');
            Eyelink('ShutDown');
        end
        ListenChar(0); clear screen; error('User terminated script with ESCAPE key.')
        %%%%%%%%%%%%%%%%%%%%%%%
    end
    
    % Abort if answer takes too long
    if secs - t0 > aborttime
        break
    end
end
%% Wating that all keys are released and delete texture
KbReleaseWait; %Keyboard
KbReleaseWait(1); %Mouse
if drawImage == 1
    Screen('Close', stimuli);
end
%% Calculating the rection time and the position
RT                = (secs - t0)*1000;                                          % converting RT to millisecond
end

