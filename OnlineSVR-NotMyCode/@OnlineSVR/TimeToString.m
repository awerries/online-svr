%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Convert a number (in seconds) to a string

function [TotalTime] = TimeToString (SVR, Time)

    Time = fix(Time);    
    TotalTime = [];
    
    % Days
    if (Time >= 60*60*24) 
        Days = mod(floor(Time/(60*60*24)),60*60*24);
        if (Days==1)
            TotalTime = [TotalTime num2str(Days) ' day, '];
        else
            TotalTime = [TotalTime num2str(Days) ' days, '];
        end
    end

    % Hours
    if (Time >= 60*60)
        Hours = mod(floor(Time/(60*60)),60*60);
        if (Hours==1)
            TotalTime = [TotalTime num2str(Hours) ' hour, '];
        else
            TotalTime = [TotalTime num2str(Hours) ' hours, '];
        end
    end

    % Minutes
    if (Time >= 60)
        Minutes = mod(floor(Time/60),60);
        if (Minutes==1)
            TotalTime = [TotalTime num2str(Minutes) ' minute and '];
        else
            TotalTime = [TotalTime num2str(Minutes) ' minutes and '];
        end
    end

    % Seconds
    Seconds = mod(Time,60);
    if (Seconds==1)
        TotalTime = [TotalTime num2str(Seconds) ' second'];
    else
        TotalTime = [TotalTime num2str(Seconds) ' seconds'];
    end

end