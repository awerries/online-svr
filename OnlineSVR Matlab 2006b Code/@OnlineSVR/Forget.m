%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Forget old samples

function [SVR, Flops] = Forget (SVR, SamplesIndexes)

    % Inizializations
    SamplesNumber = length(SamplesIndexes);
    SamplesIndexes = reshape(SamplesIndexes,SamplesNumber,1);
    StartTime = clock;
    
    % Check the indexes
    if (any(SamplesIndexes<=0) || any(SamplesIndexes>SVR.SamplesTrainedNumber))
        error('Cannot start the unlearning process. Some samples indexes are not valid.');
    end
    SamplesIndexes = sort(SamplesIndexes);
    
    % Make the video
    if (SVR.MakeVideo)
        if (exist('Temporary OnlineSVR Files'))
            rmdir('Temporary OnlineSVR Files','s');
        end
        mkdir('Temporary OnlineSVR Files');
        SVR.FramesNumber = 0;
    end
    
    % Continue the forgetting
    ShowMessage(SVR, 'Start Forgetting...',1);
    Flops = 0;
    for i=SamplesNumber:-1:1
        
        % Forget a sample
        ShowMessage(SVR, ' ', 2);
        ShowMessage(SVR, ['Forgetting ' num2str(SamplesNumber-i+1) '/' num2str(SamplesNumber)], 1);
        if (i<SamplesNumber && SamplesIndexes(i)==SamplesIndexes(i+1))
            continue;
        else
            SampleIndex = SamplesIndexes(i);
        end
        [SVR, CurrentFlops] = Unlearn(SVR, SampleIndex);
        Flops = Flops + CurrentFlops;

        % Show the plot
        if (SVR.MakeVideo>0)
            SVR = BuildPlot(SVR);
        end

    end

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
    ShowMessage(SVR, ['Forgetted ' num2str(SamplesNumber) ' elements correctly in ' TimeToString(SVR, LearningTime) '.'], 1);
    
    % Make the video
    if (SVR.MakeVideo)
        BuildVideo(SVR);
        rmdir('Temporary OnlineSVR Files','s');
    end
    
end
