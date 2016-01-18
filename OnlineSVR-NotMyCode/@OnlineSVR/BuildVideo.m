%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Build a video of a training

function [SVR] = BuildVideo (SVR)

    % Check
    if (~exist('Temporary OnlineSVR Files'))
        error('Impossible build the video: "Temporary OnlineSVR Files" not found."');
    end
    
    % Default video name
    Title = [SVR.VideoTitle '.avi'];
    if (strcmp(Title,'.avi'))
        Title = 'Learning.avi';
    end
    
    % Delete the old video if already exists
    if (exist(Title))
        delete(Title);
    end
    
    % Make the video
    ShowMessage(SVR, ' ',1);
    ShowMessage(SVR, 'Building the video...', 1);
    StartTime = clock;
    Video = avifile(Title, 'FPS', 5, 'Quality', 100, 'Compression', 'None');
    warning off;
    for i=1:SVR.FramesNumber
        FrameName = ['Temporary OnlineSVR Files/' num2str(i) '.png'];
        if (~exist(FrameName))
            Video = close(Video);
            error('Frame not found.');            
        end
        ShowMessage(SVR, ['Frame ' num2str(i) '/' num2str(SVR.FramesNumber)],2);
        Frame = imread(FrameName);
        Video = addframe(Video,Frame);        
    end
    Video = addframe(Video,Frame);
    Video = addframe(Video,Frame);
    warning on;
    Video = close(Video);
    
    % Show execution time
    EndTime = clock;
    BuildTime = fix(etime(EndTime,StartTime));
    ShowMessage(SVR, ['Video created correctly in ' TimeToString(SVR, BuildTime) '.'],1);    
    
end