%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Try to find the best values of C and KernelParam

function [SVR] = FindSolution (SVR, TrainingSetX, TrainingSetY, ValidationSetX, ValidationSetY, ErrorTollerance)

    % Other Parameters
    CMax = 200;
    KernelParamMax = 200;
    Step = 5;
    
    % Initialization
    SVR = OnlineSVR;
    SVR.KernelType = 'Polynomial';
    SVR.KernelParam = 30;
    SVR.C = 30;
    SVR.Epsilon = ErrorTollerance / 10;
    SVR.Verbosity = 0;
    SVR.ShowPlots = 0;
    IterationCount = 0;
    
    % Error Matrix Initialization
    RowsNumber = CMax + 2;
    ColsNumber = KernelParamMax + 2;
    MaxErrors = zeros(RowsNumber,ColsNumber);
    MeanErrors = zeros(RowsNumber,ColsNumber);
    MeanErrors(1,:)=inf; MeanErrors(RowsNumber,:) = inf; MeanErrors(:,1) = inf; MeanErrors(:,ColsNumber) = inf;
    MaxErrors(1,:)=inf; MaxErrors(RowsNumber,:) = inf; MaxErrors(:,1) = inf; MaxErrors(:,ColsNumber) = inf;    
    
    CIndex = SVR.C + 1;
    KernelParamIndex = SVR.KernelParam + 1;
    
    disp(' ');
    disp('OnlineSVR Self-Learning Process');
    disp(' ');
    
    
    % Phase 1 - Train the OnlineSVR
    IterationCount = IterationCount + 1;
    disp([num2str(IterationCount) ') Trying with C=' num2str(SVR.C) ' and KernelParam=' num2str(SVR.KernelParam)]);
    SVR=Train(SVR, TrainingSetX,TrainingSetY);    
    [SVR, MinError, MeanErrors(CIndex,KernelParamIndex), MaxErrors(CIndex,KernelParamIndex)] = FindError(SVR, ValidationSetX, ValidationSetY);
    
    % Phase 2 - Calibration of the parameters
    while (MaxErrors(CIndex,KernelParamIndex)>ErrorTollerance)
                   
        % Check the nearest positions
        % Left
        if (~MeanErrors(CIndex,KernelParamIndex-Step))
            SVR.C = CIndex-1;
            SVR.KernelParam = KernelParamIndex-1 - Step;
            IterationCount = IterationCount + 1;
            disp([num2str(IterationCount) ') Trying with C=' num2str(SVR.C) ' and KernelParam=' num2str(SVR.KernelParam)]);            
            [SVR MinError MeanErrors(CIndex,KernelParamIndex-Step) MaxErrors(CIndex,KernelParamIndex-Step)] = FindError(SVR, ValidationSetX, ValidationSetY);
        end
        % Right
        if (~MeanErrors(CIndex,KernelParamIndex+Step))
            SVR.C = CIndex-1;
            SVR.KernelParam = KernelParamIndex-1 + Step;
            IterationCount = IterationCount + 1;
            disp([num2str(IterationCount) ') Trying with C=' num2str(SVR.C) ' and KernelParam=' num2str(SVR.KernelParam)]);            
            [SVR MinError MeanErrors(CIndex,KernelParamIndex+Step) MaxErrors(CIndex,KernelParamIndex+Step)] = FindError(SVR, ValidationSetX, ValidationSetY);
        end
        % Up
        if (~MeanErrors(CIndex-Step,KernelParamIndex))
            SVR.C = CIndex-1 -Step;
            SVR.KernelParam = KernelParamIndex-1;
            IterationCount = IterationCount + 1;
            disp([num2str(IterationCount) ') Trying with C=' num2str(SVR.C) ' and KernelParam=' num2str(SVR.KernelParam)]);            
            [SVR MinError MeanErrors(CIndex-Step,KernelParamIndex) MaxErrors(CIndex-Step,KernelParamIndex)] = FindError(SVR, ValidationSetX, ValidationSetY);
        end
        % Down
        if (~MeanErrors(CIndex+Step,KernelParamIndex))
            SVR.C = CIndex-1 + Step;
            SVR.KernelParam = KernelParamIndex-1;
            IterationCount = IterationCount + 1;
            disp([num2str(IterationCount) ') Trying with C=' num2str(SVR.C) ' and KernelParam=' num2str(SVR.KernelParam)]);            
            [SVR MinError MeanErrors(CIndex+Step,KernelParamIndex) MaxErrors(CIndex+Step,KernelParamIndex)] = FindError(SVR, ValidationSetX, ValidationSetY);
        end
        
        % Find the next move
        [MinValue MinIndex] = min ([MeanErrors(CIndex,KernelParamIndex) MeanErrors(CIndex,KernelParamIndex-Step) MeanErrors(CIndex-Step,KernelParamIndex) MeanErrors(CIndex,KernelParamIndex+Step) MeanErrors(CIndex+Step,KernelParamIndex)]);
        switch (MinIndex)
            case 1
                % The current solution is the best
                SVR.C = CIndex-1;
                SVR.KernelParam = KernelParamIndex-1;
                if (Step == 5)
                    Step = 1;
                else
                    % If Step=1, no more precision aviable, so stop
                    SVR.Stabilize;
                    break;
                end
            case 2
                % The left solution is better
                KernelParamIndex = KernelParamIndex - Step;                
            case 3
                % The up solution is better
                CIndex = CIndex - Step;
            case 4
                % The right solution is better
                KernelParamIndex = KernelParamIndex + Step;                
            case 5
                % The down solution is better
                CIndex = CIndex + Step;
        end
        
    end    
    
    % Final Message
    if (MaxErrors(CIndex,KernelParamIndex)<ErrorTollerance)
        disp(' ');    
        disp('The OnlineSVR has found an acceptable solution at the problem.');
    else
        disp(' ');    
        disp('The OnlineSVR hasn''t found an acceptable solution at the problem.');
    end

end


function [SVR, MinError, MeanError, MaxError] = FindError (SVR, ValidationSetX, ValidationSetY)
        % Stabilize the SVR with the new parameters
        SVR = Stabilize(SVR);
        
        % Check the errors
        Error = abs(Margin(SVR, ValidationSetX,ValidationSetY));
        MinError = min(Error);
        MeanError = mean(Error);
        MaxError = max(Error);
        disp(['   > Min Error:  ' num2str(MinError)]);
        disp(['   > Mean Error: ' num2str(MeanError)]);
        disp(['   > Max Error:  ' num2str(MaxError)]);   
end
