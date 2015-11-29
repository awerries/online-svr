%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Variation Lc2 (Learning)

function [Lc2] = FindVariationLc2 (SVR, CIndex, q)

    % LC2
    if (SupportSetElementsNumber(SVR)>0)
        if (q>0)
            Lc2 = -SVR.Weights(CIndex) +SVR.C;
        else
            Lc2 = -SVR.Weights(CIndex) -SVR.C;
        end        
    else
        Lc2 = q*inf;
    end

    % Check NaN
    Lc2(isnan(Lc2)) = q*inf;
    
end
