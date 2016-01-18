%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Variations Le (Learning and Unlearning)

function [Le] = FindVariationsLe (SVR, H, Gamma, q)

% LE
if (ErrorSetElementsNumber(SVR)>0)
    ErrorGamma = Gamma(SVR.ErrorSetIndexes);
    ErrorWeights = SVR.Weights(SVR.ErrorSetIndexes);
    ErrorH = H(SVR.ErrorSetIndexes);
    
    Le = [];
    for i=1:ErrorSetElementsNumber(SVR)
        if (q*ErrorGamma(i)==0)
            Le(i) = q*inf;
        elseif (q*ErrorGamma(i)>0)
            if (ErrorWeights(i)>0) %==SVR.C)
                if (ErrorH(i)<-SVR.Epsilon)
                    Le(i) = (-ErrorH(i) -SVR.Epsilon) / ErrorGamma(i);
                else
                    Le(i) = q*inf;
                end
            else
                if (ErrorH(i)<SVR.Epsilon)
                    Le(i) = (-ErrorH(i) +SVR.Epsilon) / ErrorGamma(i);
                else
                    Le(i) = q*inf;
                end
            end
        else
            if (ErrorWeights(i)>0)%==SVR.C)
                if (ErrorH(i)>-SVR.Epsilon)
                    Le(i) = (-ErrorH(i) -SVR.Epsilon) / ErrorGamma(i);
                else
                    Le(i) = q*inf;
                end
            else
                if (ErrorH(i)>SVR.Epsilon)
                    Le(i) = (-ErrorH(i) +SVR.Epsilon) / ErrorGamma(i);
                else
                    Le(i) = q*inf;
                end
            end
        end
    end
    
else
    Le = q*inf;
end

% Check NaN
Le(isnan(Le)) = q*inf;

% Check Sign
if (any(SIGN(SVR, Le)==-SIGN(SVR, q) & Le~=0))
    save 'Error' 'SVR';
    error('sign le not valid');
end

end
