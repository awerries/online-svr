%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Stabilize the weigths of an instable OnlineSVR

function [SVR, Flops] = Stabilize (SVR)
    
    % Initialization
    StartTime = clock;
    ShowMessage(SVR, 'Start Stabilize',1);
    
    % Stabilize Weights
    CurrentSample = 0;
    SamplesToCheck = SVR.SamplesTrainedNumber;
    i = 1;
    Flops = 0;
    while (i<=SamplesToCheck)        
        CurrentSample = CurrentSample + 1;
        if (~VerifyKKTConditions(SVR, i))
            ShowMessage(SVR, ' ', 2);
            ShowMessage(SVR, ['Stabilizing ' num2str(CurrentSample) '/' num2str(SVR.SamplesTrainedNumber)],1);
            Xc = SVR.X(i,:);
            Yc = SVR.Y(i);
            [SVR, CurrentFlops] = Unlearn(SVR, i);
            Flops = Flops + CurrentFlops;
            [SVR, CurrentFlops] = Learn(SVR, Xc,Yc);            
            Flops = Flops + CurrentFlops;
            SamplesToCheck = SamplesToCheck - 1;
        else
            i =  i + 1;
        end
    end
        
    % Check the final OnlineSVR
    if (~VerifyKKTConditions(SVR))
        disp('OnlineSVR not yet stabilized.');
    else
        % Show execution time
        EndTime = clock;
        StabilizingTime = fix(etime(EndTime,StartTime));    
        ShowMessage(SVR, ' ', 2);
        ShowMessage(SVR, ['Stabilized the OnlineSVR correctly in ' TimeToString(SVR, StabilizingTime) '.'],1);        
    end
   
end