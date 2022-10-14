function [thetaX, thetaY] = calcAngle(rect,pixelX,pixelY,distance,mmX,mmY)

switch nargin
    case 3
        %% defaults
        
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
        mixpixelX = pixelX/2;
        midpixelY = pixelY/2;
        
        % total mm size of the screen in the eyetracker
        mmX = 531;
        mmY = 299;
        
        % middle of the screen in mm
        midmmX = mmX/2;
        midmmY = mmY/2;
        
        % eye to screen distance in mm in the eyetracker
        distance = 800;
        
        %% convert rect from pixel to mm
        pix2mmX = pixelX/mmX; % pixel per mm
        pix2mmY = pixelY/mmY; % pixel per mm
        mm2pixX = mmX/pixelX; % mm per pixel
        mm2pixY = mmY/pixelY; % mm per pixel
        mmRect = [xStart*mm2pixX, yStart*mm2pixY, (xStart+xLength)*mm2pixX, (yStart+yLength)*mm2pixY];
        
        
        %% change reference to the center point
        mmRectM = [mmRect(1)-midmmX, mmRect(2)-midmmY, mmRect(3)-midmmX, mmRect(4)-midmmY];
        
        
        %% visual angle calculation
        
        % inverse tan function (also knows as atan) ?
        % ? = atan(Opposite / Adjacent) or
        % ? = atan(Size / Distance)
        
        if(mmRectM(3)<=0 && mmRectM(1)<=0 && mmRectM(1)<mmRectM(3)) % left side
            thetaX = rad2deg(atan(abs(mmRectM(1))/distance)) - rad2deg(atan(abs(mmRectM(3))/distance));
        elseif(mmRectM(3)>0 && mmRectM(1)>0 && mmRectM(1)<mmRectM(3)) % right side
            thetaX = rad2deg(atan(abs(mmRectM(3))/distance)) - rad2deg(atan(abs(mmRectM(1))/distance));
        elseif(mmRectM(3)>=0 && mmRectM(1)<=0) % centered
            thetaX = rad2deg(atan(abs(mmRectM(3))/distance)) + rad2deg(atan(abs(mmRectM(1))/distance));
        end
        
        if(mmRectM(4)<=0 && mmRectM(2)<=0 && mmRectM(2)<mmRectM(4)) % bottom side
            thetaY = rad2deg(atan(abs(mmRectM(2))/distance)) - rad2deg(atan(abs(mmRectM(4))/distance));
        elseif(mmRectM(4)>0 && mmRectM(2)>0 && mmRectM(2)<mmRectM(4)) % top side
            thetaY = rad2deg(atan(abs(mmRectM(4))/distance)) - rad2deg(atan(abs(mmRectM(2))/distance));
        elseif(mmRectM(4)>=0 && mmRectM(2)<=0) % centered
            thetaY = rad2deg(atan(abs(mmRectM(4))/distance)) + rad2deg(atan(abs(mmRectM(2))/distance));
        end
        
        
        
        % convert from mm to pixels
        
        % Now that we can compute visual angle for objects that can be measured in mm,
        % it is a relatively simple step to move between mm and screen pixels.
        % If we know our screen pixel resolution (e.g. 1920×1080)
        % as well as its dimensions (height and width in mm)
        % it is very easy to work out how many pixels there are per mm.
        % For example, in the horizontal direction, a screen with 1920 pixels,
        % that measures 520mm wide, has 1920/520 = 3.89 pixels per mm.
        % Another way of looking at things is to say that each pixel on the screen
        % is 520/1920 = 0.27mm wide.
        
        
    otherwise
        
        %% defaults
        
        % image length in pixels on the screen in the eyetracker
        xLength = rect(3)-rect(1);
        yLength = rect(4)-rect(2);
        
        % image starting points on the screen in pixels
        xStart = rect(1);
        yStart = rect(2);
        
        % image position on the screen in pixels
        pixelRect = [xStart, yStart, xStart+xLength, yStart+yLength];
        
        
        % middle of the screen in pixels
        midpixelX = pixelX/2;
        midpixelY = pixelY/2;
        
        % middle of the screen in mm
        midmmX = mmX/2;
        midmmY = mmY/2;
        
        
        %% convert rect from pixel to mm
        pix2mmX = pixelX/mmX; % pixel per mm
        pix2mmY = pixelY/mmY; % pixel per mm
        mm2pixX = mmX/pixelX; % mm per pixel
        mm2pixY = mmY/pixelY; % mm per pixel
        mmRect = [xStart*mm2pixX, yStart*mm2pixY, (xStart+xLength)*mm2pixX, (yStart+yLength)*mm2pixY];
        
        
        %% change reference to the center point
        mmRectM = [mmRect(1)-midmmX, mmRect(2)-midmmY, mmRect(3)-midmmX, mmRect(4)-midmmY];
        
        
        %% visual angle calculation
        
        % inverse tan function (also knows as atan) ?
        % ? = atan(Opposite / Adjacent) or
        % ? = atan(Size / Distance)
        
        if(mmRectM(3)<=0 && mmRectM(1)<=0 && mmRectM(1)<mmRectM(3)) % left side
            thetaX = rad2deg(atan(abs(mmRectM(1))/distance)) - rad2deg(atan(abs(mmRectM(3))/distance));
        elseif(mmRectM(3)>0 && mmRectM(1)>0 && mmRectM(1)<mmRectM(3)) % right side
            thetaX = rad2deg(atan(abs(mmRectM(3))/distance)) - rad2deg(atan(abs(mmRectM(1))/distance));
        elseif(mmRectM(3)>=0 && mmRectM(1)<=0) % centered
            thetaX = rad2deg(atan(abs(mmRectM(3))/distance)) + rad2deg(atan(abs(mmRectM(1))/distance));
        end
        
        if(mmRectM(4)<=0 && mmRectM(2)<=0 && mmRectM(2)<mmRectM(4)) % bottom side
            thetaY = rad2deg(atan(abs(mmRectM(2))/distance)) - rad2deg(atan(abs(mmRectM(4))/distance));
        elseif(mmRectM(4)>0 && mmRectM(2)>0 && mmRectM(2)<mmRectM(4)) % top side
            thetaY = rad2deg(atan(abs(mmRectM(4))/distance)) - rad2deg(atan(abs(mmRectM(2))/distance));
        elseif(mmRectM(4)>=0 && mmRectM(2)<=0) % centered
            thetaY = rad2deg(atan(abs(mmRectM(4))/distance)) + rad2deg(atan(abs(mmRectM(2))/distance));
        end
        
        
        
end

end