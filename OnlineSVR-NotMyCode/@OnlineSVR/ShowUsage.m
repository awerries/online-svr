%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Show how to use OnlineSVR

function [] = ShowUsage (SVR)

    % Usage
    disp (' ');
    disp ('Usage:   SVR = OnlineSVR;');

    % OnlineSVR Attributes
    disp (' ');    
    disp ('Attributes usage:   val = get(SVR, ''AttributeName'');');
    disp ('                    SVR = set(SVR, ''AttributeName'', ''AttributeValue'');');
    disp (' ');    
    disp ('OnlineSVR Attributes:');
    disp('> Epsilon                         Epsilon Parameter (Default:0.1)');
    disp('> C                               C Parameter (Default:1)');
    disp('> KernelType                      Type of Kernel (Default:RBF)');
    disp('> KernelParam                     Kernel Function Parameter (Default:30)');
    disp('> KernelParam2                    Kernel Function Parameter2 (Default:0)');
    disp('> AutoErrorTollerance             Enable  auto error tollerance (Default:true)');
    disp('> ErrorTollerance                 Error Tollerance Parameter (Default:Epsilon/10)');
    disp('> StabilizedLearning              Correct errors of training (Default:true)');
    
    % Video Attributes
    disp (' ');
    disp ('Video Attributes:');
    disp ('> ShowPlots                      Shows OnlineSVR plots during trainings (Default:true)');
    disp ('> MakeVideo                      Make a training video (Default:false)');
    disp ('> VideoTitle                     Video Title');
    disp ('> FramesNumber                   Frames per second (Default:10)');
    
    % Other Attributes
    disp (' ');
    disp ('Other Attributes:');
    disp ('> X                              Training Set X');
    disp ('> Y                              Training Set Y');
    disp ('> Weights                        Training Set Weigths');
    disp ('> Bias                           Bias');
    disp ('> SupportSetIndexes              Support Set Indexes');
    disp ('> ErrorSetIndexes                Error Set Indexes');
    disp ('> RemainingSetIndexes            Remaining Set Indexes');
    disp ('> SamplesTrainedNumber           Samples Trained Number');    
    
    % OnlineSVR Methods
    disp (' ');
    disp ('OnlineSVR Methods:');
    disp ('> Train(SVR, X,Y)                Train samples (X,Y)');
    disp ('> Forget(SVR, Indexes)           Forget samples');
    disp ('> Stabilize(SVR)                 Stabilize OnlineSVR');
    disp ('> Predict(SVR, X)                Predict Y values of X');
    disp ('> Margin(SVR, X, Y)              Predict values of X and subtract it to Y');
    disp ('> VerifyKKYConditions(SVR)       Returns true if KKT conditions are verified');
    
    % Plot Methods
    disp (' ');
    disp ('Plot Methods:');
    disp ('> BuildPlot(SVR)                 Build plot of current OnlineSVR');    
    
    % I/O Methods
    disp (' ');
    disp ('Other Methods:');
    disp ('> ShowInfo(SVR)                  Show Info about current OnlineSVR');    
    disp ('> ShowDetails(SVR)               Show Details about current OnlineSVR');    
    disp (' ');
        
end