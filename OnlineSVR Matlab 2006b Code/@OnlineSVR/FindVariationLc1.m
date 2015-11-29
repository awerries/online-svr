%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Variation Lc1 (Learning)

function [Lc1] = FindVariationLc1 (SVR, H, Gamma, CIndex, q)

    % LC1
    if (Gamma(CIndex)<=0)
        Lc1 = q*inf;  
    elseif (H(CIndex)>+SVR.Epsilon && -SVR.C<SVR.Weights(CIndex) && SVR.Weights(CIndex)<=0) 
        Lc1 = (-H(CIndex) +SVR.Epsilon) / Gamma(CIndex);
    elseif (H(CIndex)<-SVR.Epsilon && 0<=SVR.Weights(CIndex) && SVR.Weights(CIndex)<=SVR.C)
        Lc1 = (-H(CIndex) -SVR.Epsilon) / Gamma(CIndex);
    end
    
    % Check NaN
    Lc1(isnan(Lc1)) = q*inf;
    
end
