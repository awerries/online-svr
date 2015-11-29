%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% OnlineSVR Examples

% Initializations
clear all;
close all;
clear classes;

% Build the OnlineSVR
SVR = OnlineSVR;

% Set Parameters
SVR = set(SVR,      'C',                    10, ...
                    'Epsilon',              0.1, ...
                    'KernelType',           'RBF', ...
                    'KernelParam',          30, ...
                    'AutoErrorTollerance',  true, ...
                    'Verbosity',            1, ...
                    'StabilizedLearning',   true, ...
                    'ShowPlots',            true, ...
                    'MakeVideo',            false, ...
                    'VideoTitle',           '');

% Build Training set
TrainingSetX = rand(20,1);
TrainingSetY = sin(TrainingSetX*pi*2);

% Training
SVR = Train(SVR, TrainingSetX,TrainingSetY);

% Show Info
ShowInfo (SVR);

% Predict some values
TestSetX = [0; 1];
TestSetY = sin(TestSetX*pi*2);
PredictedY = Predict(SVR, TestSetX);
Errors = Margin(SVR, TestSetX,TestSetY);
disp(' ');
disp('Some results:');
disp(['f(0)=' num2str(PredictedY(1)) '     y(0)=' num2str(TestSetY(1)) '     margin=' num2str(Errors(1))]);
disp(['f(1)=' num2str(PredictedY(2)) '     y(1)=' num2str(TestSetY(2)) '     margin=' num2str(Errors(2))]);
disp(' ');

% Forget first 4 samples
SVR = Forget(SVR, 1:4);

% Build plot
BuildPlot(SVR);

