%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Train the OnlineSVR with new data

function [SVR, Flops] = Train (SVR, NewSamplesX, NewSamplesY)    

    % Inizialization
    SamplesNumber = size(NewSamplesX,1);
    StartTime = clock;
        
    % Make the video
    if (SVR.MakeVideo)
        if (exist('Temporary OnlineSVR Files'))
            rmdir('Temporary OnlineSVR Files','s');
        end
        mkdir('Temporary OnlineSVR Files');
        SVR.FramesNumber = 0;
    end

    % Continue the training
    ShowMessage(SVR, 'Start Training...',1);
    Flops = 0;
    for i=1:SamplesNumber
        
        % Check if the sample is already added
        Index = INDEXOF(SVR, SVR.X, NewSamplesX(i,:));
        if (Index>0 && SVR.Y(Index)==NewSamplesY(i))
            continue;
        end
        
        % Train a new sample
        ShowMessage(SVR, ' ', 2);
        ShowMessage(SVR, ['Training ' num2str(i) '/' num2str(SamplesNumber)], 1); 
        [SVR, CurrentFlops] = Learn(SVR, NewSamplesX(i,:), NewSamplesY(i));  
        Flops = Flops + CurrentFlops;
        Iterations(i) = Flops;
        % Show the plot
        if (SVR.MakeVideo>0)
            SVR = BuildPlot(SVR);
        end
    end
    save 'Iterations.txt' 'Iterations' -ASCII -DOUBLE -TABS;

    % Stabilized Learning
    if (SVR.StabilizedLearning)
        StabilizationsNumber = 0;
        while (~VerifyKKTConditions(SVR))
            [SVR, CurrentFlops] = Stabilize(SVR);
            Flops = Flops + CurrentFlops;
            StabilizationsNumber = StabilizationsNumber + 1;
            if (StabilizationsNumber > SVR.SamplesTrainedNumber)
                disp(['It''s impossible to stabilize the OnlineSVR. Please add or remove some new samples.']);
                break;
            end
        end
    end
    
    % Show execution time
    EndTime = clock;
    LearningTime = fix(etime(EndTime,StartTime));
    ShowMessage(SVR, ' ',2);
    ShowMessage(SVR, ['Trained ' num2str(SamplesNumber) ' elements correctly in ' TimeToString(SVR, LearningTime) '.'],1);
    
    % Build the video
    if (SVR.MakeVideo)
        BuildVideo(SVR);
        rmdir('Temporary OnlineSVR Files','s');
    end
    
end
