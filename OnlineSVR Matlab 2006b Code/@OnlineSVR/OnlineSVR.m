%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Class SVR - Online Support Vector Regression

function [SVR] = OnlineSVR
        
        % SVR parameters
        SVR.C = 1;                              % Depends 
        SVR.Epsilon = 0.1;                      % Error Tollerance
        SVR.KernelType = 'Linear';              % Type of Kernel (see Kernel.h for more informations)
        SVR.KernelParam = 30;                   % Parameter of the Kernel Function
        SVR.KernelParam2 = 0;                   % Parameter of the Kernel Function (for MLP kernel)
        
        % Training Set
        SVR.SamplesTrainedNumber = 0;           % Number of samples trained
        SVR.X = [];                             % Samples X Matrix (one for each row)
        SVR.Y = [];                             % Samples Y Vector
        
        % Weights
        SVR.Weights = [];                       % Weights of the support vector machine (one for each sample)
        SVR.Bias = 0;                           % Bias of the support vector
        
        % Verbosity
        SVR.Verbosity = 1;                      % Verbosity Level (see Verbosity.h for more informations)
        
        % Stabilized Learning
        SVR.StabilizedLearning = true;          % If true, stabilize the weights after a training or forgetting

        % Error Tollerance
        SVR.AutoErrorTollerance = false;        % Enable or not auto error tollerance
        SVR.ErrorTollerance = 0.01;             % Manual Error tollerance
        
        % Display
        SVR.ShowPlots = 1;                      % If true, at the end of training/forgetting the svm build an image of the svm
        SVR.MakeVideo = 0;                      % If true, it make a video of the training/forgetting process (warning: it's slow)
        SVR.VideoTitle = '';                    % Title of the video build if the 'MakeVideo' option is enabled
        SVR.FramesNumber = 10;                  % Frames for second used to build the video
        
        % Working Set        
        SVR.SupportSetIndexes = [];             % List of indexes of the SupportSet samples
        SVR.ErrorSetIndexes = [];               % List of indexes of the ErrorSet samples        
        SVR.RemainingSetIndexes = [];           % List of indexes of the RemainingSet samples        
        SVR.R = [];                             % R Matrix (contains informations about the support vector samples)

        SVR = class(SVR,'OnlineSVR');

end
