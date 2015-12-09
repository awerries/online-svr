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

load('traffic_data.mat')

% Build the OnlineSVR
SVR = OnlineSVR;

% Set Parameters
SVR = set(SVR,      'C',                    10, ...
                    'Epsilon',              0.1, ...
                    'KernelType',           'RBF', ...
                    'KernelParam',          30, ...
                    'AutoErrorTollerance',  true, ...
                    'Verbosity',            1, ...
                    'StabilizedLearning',   false, ...
                    'ShowPlots',            true, ...
                    'MakeVideo',            false, ...
                    'VideoTitle',           '');

% Build Training set
y1_avg = avg_arrival_rate(x1,y1);%preprocessing
window_size = 12;
start = 300;


TrainingSetX = y1_avg(start:start+window_size)';
TrainingSetY = y1_avg(start+window_size+1);
start_size = 100;
horizon = 3;
for i = 1:start_size-1
    TrainingSetX = cat(1,TrainingSetX,y1_avg(start+i:start+i+window_size)');
    TrainingSetY = cat(1,TrainingSetY,mean(y1_avg(start+i+window_size+1:start+i+window_size+horizon)));
end

% Training
SVR = Train(SVR, TrainingSetX,TrainingSetY);

% Show Info
ShowInfo (SVR);

%Online Learning 
online_size = 500;
Errors = zeros(online_size,1);
PredictedY = zeros(online_size,1);
AnsY = zeros(online_size,1);
for i = 1:online_size
    OnlineSetX = y1_avg(start+start_size+i:start+start_size+i+window_size)';
    PredictedY(i) = Predict(SVR, OnlineSetX);
    OnlineSetY = mean(y1_avg(start+start_size+i+window_size+1:start+start_size+i+window_size+horizon)); %y1_avg(start+start_size+i+window_size+1);
    AnsY(i) = OnlineSetY;
    Errors(i) = Margin(SVR, OnlineSetX,OnlineSetY);
    SVR = Forget(SVR, 1:1);
    SVR = Learn(SVR, OnlineSetX,OnlineSetY);
end


figure;
plot(1:online_size,PredictedY, 1:online_size,AnsY);


% % Predict some values
% index = randi(5000,50,1);
% TestSetX = x1(index);
% TestSetY = y1(index);
% PredictedY = Predict(SVR, TestSetX);
% Errors = Margin(SVR, TestSetX,TestSetY);
% disp(' ');
% disp('Some results:');
% disp(['f(0)=' num2str(PredictedY(1)) '     y(0)=' num2str(TestSetY(1)) '     margin=' num2str(Errors(1))]);
% disp(['f(1)=' num2str(PredictedY(2)) '     y(1)=' num2str(TestSetY(2)) '     margin=' num2str(Errors(2))]);
% disp(' ');
% 
% % Forget first 4 samples
% SVR = Forget(SVR, 1:4);
% 
% % Build plot
% BuildPlot(SVR);

