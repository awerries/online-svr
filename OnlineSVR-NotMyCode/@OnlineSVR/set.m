%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Set Method

function SVR = set(SVR , varargin)

    while length(varargin) >= 2,
       Property = varargin{1};
       Value = varargin{2};
       varargin = varargin(3:end);

       switch upper(Property)
           
            % SVR parameters
            case 'C'
               SVR.C = Value;
            case 'EPSILON'
               SVR.Epsilon = Value;
            case 'KERNELTYPE'
               SVR.KernelType = Value;
            case 'KERNELPARAM'
               SVR.KernelParam = Value;

            % TrainingSet
            case 'SAMPLESTRAINEDNUMBER'
               SVR.SamplesTrainedNumber = Value;
            case 'X'
               SVR.X = Value;
            case 'Y'
               SVR.Y = Value;

            % Weights
            case 'WEIGHTS'
               SVR.Weights = Value;
            case 'BIAS'
               SVR.Bias = Value;

            % Verbosity
            case 'VERBOSITY'
               SVR.Verbosity = Value;

            % Stabilized Learning
            case 'STABILIZEDLEARNING'
               SVR.StabilizedLearning = Value;

            % Error Tollerance
            case 'AUTOERRORTOLLERANCE'
               SVR.AutoErrorTollerance = Value;
            case 'ERRORTOLLERANCE'
               SVR.ErrorTollerance = Value;

            % Display
            case 'SHOWPLOTS'
               SVR.ShowPlots = Value;
            case 'MAKEVIDEO'
               SVR.MakeVideo = Value;
            case 'VIDEOTITLE'
               SVR.VideoTitle = Value;
            case 'FRAMESNUMBER'
               SVR.FramesNumber = Value;

            % Working Set
            case 'SUPPORTSETINDEXES'
               SVR.SupportSetIndexes = Value;
            case 'ERRORSETINDEXES'
               SVR.ErrorSetIndexes = Value;
            case 'REMAININGSETINDEXES'
               SVR.RemainingSetIndexes = Value;
            case 'R'
               SVR.R = Value;           

            otherwise
               error([Property,' Is not a valid OnlineSVR property']);
        end
    end
end
