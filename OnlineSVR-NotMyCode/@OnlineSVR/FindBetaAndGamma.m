%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Find Beta and Gamma

function [Beta, Gamma] = FindBetaAndGamma (SVR, SampleIndex)

    % Check Parameters
    if (~exist('SampleIndex'))
        SampleIndex = SVR.SamplesTrainedNumber;
    end
    
    % Find Beta
    Qsi = Q (SVR, SVR.X(SVR.SupportSetIndexes,:), SVR.X(SampleIndex,:));
    Beta = -SVR.R * [1; Qsi];
    
    % Find Gamma
    Qxi = Q (SVR, SVR.X, SVR.X(SampleIndex,:));
    Qxs = Q (SVR, SVR.X, SVR.X(SVR.SupportSetIndexes,:));
    if (SampleIndex == 0)
       disp(Qxs)
    end
    if (SupportSetElementsNumber(SVR)==0)
        Gamma = Qxi*0+1;    % Gamma=1, so that Gamma*DeltaC = DeltaB        
    else
        Gamma = Qxi + [ones(SVR.SamplesTrainedNumber,1) Qxs] * Beta;
    end
    SVR.R
    Beta
    Gamma
    % NaN Correction
    Beta(isnan(Beta)) = 0;
    Gamma(isnan(Gamma)) = 0;         

end