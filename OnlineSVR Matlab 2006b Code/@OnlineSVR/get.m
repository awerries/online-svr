%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Get Method

function X = get(SVR, Property)
    
    switch upper(Property)
        % SVR parameters
        case 'C'
           X = SVR.C;
        case 'EPSILON'
           X = SVR.Epsilon;
        case 'KERNELTYPE'
           X = SVR.KernelType;
        
        % TrainingSet
        case 'SAMPLESTRAINEDNUMBER'
           X = SVR.SamplesTrainedNumber;
        case 'X'
           X = SVR.X;
        case 'Y'
           X = SVR.Y;
           
        % Weights
        case 'WEIGHTS'
           X = SVR.Weights;
        case 'BIAS'
           X = SVR.Bias;
        
        % Verbosity
        case 'VERBOSITY'
           X = SVR.Verbosity;
        
        % Stabilized Learning
        case 'STABILIZEDLEARNING'
           X = SVR.StabilizedLearning;
        
        % Error Tollerance
        case 'AUTOERRORTOLLERANCE'
           X = SVR.AutoErrorTollerance;
        case 'ERRORTOLLERANCE'
           X = SVR.ErrorTollerance;
           
        % Display
        case 'SHOWPLOTS'
           X = SVR.ShowPlots;
        case 'MAKEVIDEO'
           X = SVR.MakeVideo;
        case 'VIDEOTITLE'
           X = SVR.VideoTitle;
        case 'FRAMESNUMBER'
           X = SVR.FramesNumber;
          
        % Working Set
        case 'SUPPORTSETINDEXES'
           X = SVR.SupportSetIndexes;
        case 'ERRORSETINDEXES'
           X = SVR.ErrorSetIndexes;
        case 'REMAININGSETINDEXES'
           X = SVR.RemainingSetIndexes;
        case 'R'
           X = SVR.R;           
        
        otherwise
           error([Property,' Is not a valid OnlineSVR property']);
    end

end
