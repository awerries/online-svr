%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Predict the results of new samples

function [x] = Predict (SVR, PredictSetX)

    if (SVR.SamplesTrainedNumber>0)
        x = (SVR.Weights' * Kernel(SVR, SVR.X, PredictSetX))' + SVR.Bias;
    else
        x = PredictSetX*0 + SVR.Bias;
    end
    
end