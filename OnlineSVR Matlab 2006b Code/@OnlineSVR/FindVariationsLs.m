%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Variations Ls (Learning and Unlearning)

function [Ls] = FindVariationsLs (SVR, Beta, q, H)

% LS
if (SupportSetElementsNumber(SVR)>0)
    Ls = [];
    SupportWeights = SVR.Weights(SVR.SupportSetIndexes);
    SupportH = H(SVR.SupportSetIndexes);
    
    for i=1:SupportSetElementsNumber(SVR)
        if (q*Beta(i+1)==0)
            Ls(i) = q*inf;
        elseif (q*Beta(i+1)>0)
            if (SupportH(i)>0) % (SupportH(i)==+SVR.Epsilon)
                if (SupportWeights(i)<-SVR.C)
                    Ls(i) = (-SupportWeights(i) -SVR.C) / Beta(i+1);
                elseif (SupportWeights(i)<=0)
                    Ls(i) = -SupportWeights(i) / Beta(i+1);
                else
                    Ls(i) = q*inf;
                end
            else % (SupportH(i)==-SVR.Epsilon)
                if (SupportWeights(i) < 0)
                    Ls(i) = -SupportWeights(i) / Beta(i+1);
                elseif (SupportWeights(i)<=SVR.C)
                    Ls(i) = (-SupportWeights(i) +SVR.C) / Beta(i+1);
                else
                    Ls(i) = q*inf;
                end
            end
        else
            if (SupportH(i)>0) % ==SVR.Epsilon
                if (SupportWeights(i)>0)
                    Ls(i) = -SupportWeights(i) / Beta(i+1);
                elseif (SupportWeights(i) >= -SVR.C)
                    Ls(i) = (-SupportWeights(i) -SVR.C) / Beta(i+1);
                else
                    Ls(i) = q*inf;
                end
            else % (SupportH(i)==-SVR.Epsilon)
                if (SupportWeights(i) > +SVR.C)
                    Ls(i) = (-SupportWeights(i) +SVR.C) / Beta(i+1);
                elseif (SupportWeights(i) >= SVR.C)
                    Ls(i) = -SupportWeights(i) / Beta(i+1);
                else
                    Ls(i) = q*inf;
                end
            end
        end
    end
else
    Ls = q*inf;
end

% Check NaN
Ls(isnan(Ls)) = q*inf;

% Check Sign
if (any(SIGN(SVR, Ls)==-SIGN(SVR, q) & Ls~=0))
    save 'Error' 'SVR';
    error('sign ls not valid');
end

end
