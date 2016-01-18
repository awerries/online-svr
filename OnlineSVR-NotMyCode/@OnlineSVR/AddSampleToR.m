%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Add a new sample to R Matrix

function [Rnew] = AddSampleToR (SVR, SampleIndex, SampleOldSet, Beta, Gamma) 

    % Case 1: First element added
    warning off;
    if (size(SVR.R,1) <= 1)
        Rnew = ones(2,2);
        Rnew(1,1) = -Kernel(SVR, SVR.X(SampleIndex,:),SVR.X(SampleIndex,:));
        Rnew(2,2) = 0;

    % Case 2: Other elements   
    else
        % If the sample cames from error or remaining set, recompute beta and gamma
        if (strcmp(SampleOldSet,'ErrorSet') || strcmp(SampleOldSet,'RemainingSet'))
            Qii = Kernel (SVR, SVR.X(SampleIndex,:), SVR.X(SampleIndex,:));
            Qsi = Kernel (SVR, SVR.X(SVR.SupportSetIndexes(1:SupportSetElementsNumber(SVR)-1),:), SVR.X(SampleIndex,:));
            Beta = -SVR.R*[1; Qsi];
            Beta(isnan(Beta)) = 0;
            Gamma(SampleIndex) = Qii + [1 Qsi']*Beta;            
            Gamma(isnan(Gamma)) = 0;
        end
        % Add the new support vector to R
        [r c] = size (SVR.R);
        Rnew = [SVR.R zeros(r,1); zeros(1,c+1)];
        if (Gamma(SampleIndex)~=0)
            Rnew = Rnew + 1/Gamma(SampleIndex) .* [Beta; 1]*[Beta' 1];
        end
        if (any(any(isnan(Rnew))))
            error('WARNING: R becomes inconsist. Train again the OnlineSVR');
        end
    end
    warning on;
    
end
