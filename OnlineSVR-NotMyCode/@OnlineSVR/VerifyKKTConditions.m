%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Check if KKT Conditions are verified

function [x] = VerifyKKTConditions(SVR, SampleToCheck, H)

    % Simple case
    if (SVR.SamplesTrainedNumber==0)
        x = true;
        return;
    end

    % Check Parameters
    if (~exist('H'))
        H = Margin(SVR, SVR.X, SVR.Y);
    end
    if (exist('SampleToCheck'))
        SamplesToCheck = SampleToCheck;
    else
        SamplesToCheck = [1:SVR.SamplesTrainedNumber];
    end

    % Error Tollerance
    if (SVR.AutoErrorTollerance)
        Error = SVR.Epsilon / 10;
    else
        Error = SVR.ErrorTollerance;        
    end    
    
    for i=1:length(SamplesToCheck)
        % Select the sample
        SampleIndex = SamplesToCheck(i);    
        % SupportSet
        if (any(SVR.SupportSetIndexes==SampleIndex))
            if ((IsContained(SVR, SVR.Weights(SampleIndex), -SVR.C, 0, Error) && IsEquals(SVR, H(SampleIndex), SVR.Epsilon, Error)) || ...
                (IsContained(SVR, SVR.Weights(SampleIndex), 0, SVR.C, Error) && IsEquals(SVR, H(SampleIndex), -SVR.Epsilon, Error)))
                x = true;
            else
                x = false;
                return;
            end    
        % ErrorSet
        elseif (any(SVR.ErrorSetIndexes==SampleIndex))
            if ((IsEquals(SVR, SVR.Weights(SampleIndex), -SVR.C, Error) && IsContained(SVR, H(SampleIndex), SVR.Epsilon, Inf, Error)) || ...
                (IsEquals(SVR, SVR.Weights(SampleIndex), SVR.C, Error) && IsContained(SVR, H(SampleIndex), -Inf, -SVR.Epsilon, Error)))
                x = true;
            else
                x = false;
                return;
            end    
        % RemainingSet
        elseif (any(SVR.RemainingSetIndexes==SampleIndex))
            if (IsEquals(SVR, SVR.Weights(SampleIndex), 0, Error) && IsContained(SVR, H(SampleIndex), -SVR.Epsilon, SVR.Epsilon, Error))
                x = true;
            else
                x = false;
                return;
            end        
        else
        % Sample not trained
            x = true;
        end        
    end        

end
