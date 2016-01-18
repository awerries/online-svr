%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Show a message on the screen
%
% Params:
% - Message: string that contains the message
% - VerbosityLevel: level of verbosity
%
% Verbosity's Levels:
% - 0: no messages
% - 1: number of samples trained
% - 2: for each sample, the log of each action
% - 3: for each sample, the log of each action and each variation 

function [] = ShowMessage (SVR, Message, VerbosityLevel)

    if (~exist('VerbosityLevel'))
        VerbosityLevel = 0;
    end
    if (VerbosityLevel~=0 && SVR.Verbosity>=VerbosityLevel)
        disp(Message);
    end

end