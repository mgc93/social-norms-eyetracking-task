function [rectAOI] = calcAOI(rect,pixelX,pixelY,mgX,mgY,distance,mmX,mmY)

% calculate how many pixels to add to an image in order to have an addition
% 1 degree of visual angle for each margin

rectAOI = zeros(1,4);
switch nargin
    case 3
        
        %% defaults
        [thetaX,thetaY] = calcAngle(rect,pixelX,pixelY);
        mgX = 1;
        mgY = 1;
        % image length in pixels on the screen in the eyetracker
        xLength = rect(3)-rect(1);
        yLength = rect(4)-rect(2);
        
        % image starting points on the screen in pixels
        xStart = rect(1);
        yStart = rect(2);
        
        % image position on the screen in pixels
        pixelRect = [xStart, yStart, xStart+xLength, yStart+yLength];
        
%         % total pixel size of the screen in the eyetracker
%         pixelX = 1920;
%         pixelY = 1080;
        
        % middle of the screen in pixels
        midpixelX = pixelX/2;
        midpixelY = pixelY/2;
        
        % total mm size of the screen in the eyetracker
        mmX = 531;
        mmY = 299;
        
        % middle of the screen in mm
        midmmX = mmX/2;
        midmmY = mmY/2;
        
        % eye to screen distance in mm in the eyetracker
        distance = 800;
        
        %% calculate new rect
        % on the X axis
        rectMM = rect;
        thetaXAOI = thetaX;
        while(thetaXAOI<(thetaX+2*mgX))
            rectMM = rectMM+[-1,0,1,0];
            [thetaXAOI, thetaYAOI ] = calcAngle(rectMM,pixelX,pixelY,distance,mmX,mmY);
        end
        % find out how many pixels to add to one side on the X axis
        rectAOI(1,1) = rectMM(1,1);
        rectAOI(1,3) = rectMM(1,3);
        
        % on the Y axis
        rectMM = rect;
        thetaYAOI = thetaY;
        while(thetaYAOI<(thetaY+2*mgY))
            rectMM = rectMM+[0,-1,0,1];
            [thetaXAOI, thetaYAOI ] = calcAngle(rectMM,pixelX,pixelY,distance,mmX,mmY);
        end
        % find out how many pixels to add to one side on the X axis
        rectAOI(1,2) = rectMM(1,2);
        rectAOI(1,4) = rectMM(1,4);
        
    otherwise
        
        
        %% defaults
        
        % eye to screen distance in mm in the eyetracker
        distance = 800;
        
        % total mm size of the screen in the eyetracker
        mmX = 531;
        mmY = 299;
        
        [thetaX,thetaY] = calcAngle(rect,pixelX,pixelY,distance,mmX,mmY);
        % image length in pixels on the screen in the eyetracker
        xLength = rect(3)-rect(1);
        yLength = rect(4)-rect(2);
        
        % image starting points on the screen in pixels
        xStart = rect(1);
        yStart = rect(2);
        
        % image position on the screen in pixels
        pixelRect = [xStart, yStart, xStart+xLength, yStart+yLength];
        
        % middle of the screen in pixels
        mixpixelX = pixelX/2;
        midpixelY = pixelY/2;
        
        % middle of the screen in mm
        midmmX = mmX/2;
        midmmY = mmY/2;
        
        
        %% calculate new rect
        % on the X axis
        rectMM = rect;
        thetaXAOI = thetaX;
        while(thetaXAOI<(thetaX+2*mgX))
            rectMM = rectMM+[1,0,1,0];
            [thetaXAOI, ~ ] = calcAngle(rectMM,distance,mmX,mmY,pixelX,pixelY);
        end
        % find out how many pixels to add to one side on the X axis
        rectAOI(1,1) = rectMM(1,1);
        rectAOI(1,3) = rectMM(1,3);
        
        % on the Y axis
        rectMM = rect;
        thetaYAOI = thetaY;
        while(thetaYAOI<(thetaY+2*mgY))
            rectMM = rectMM+[0,1,0,1];
            [~, thetaYAOI ] = calcAngle(rectMM,distance,mmX,mmY,pixelX,pixelY);
        end
        % find out how many pixels to add to one side on the X axis
        rectAOI(1,2) = rectMM(1,2);
        rectAOI(1,4) = rectMM(1,4);
        
end

end

