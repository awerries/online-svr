%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Variations Lr (Learning and Unlearning)

function [Lr] = FindVariationsLr (SVR, H, Gamma, q)

    % LR
    if (RemainingSetElementsNumber(SVR)>0)
        Lr = [];
        RemainingGamma = Gamma(SVR.RemainingSetIndexes);
        RemainingH = H(SVR.RemainingSetIndexes);
        
        for i=1:RemainingSetElementsNumber(SVR)
            if (q*RemainingGamma(i)==0)
                Lr(i) = q*inf;
            elseif (q*RemainingGamma(i)>0)
                if (RemainingH(i) < -SVR.Epsilon)
                    Lr(i) = (-RemainingH(i) -SVR.Epsilon) / RemainingGamma(i);
                elseif (RemainingH(i) < +SVR.Epsilon)
                    Lr(i) = (-RemainingH(i) +SVR.Epsilon) / RemainingGamma(i);
                else
                    Lr(i) = q*inf;
                end
            else
                if (RemainingH(i) > +SVR.Epsilon)
                    Lr(i) = (-RemainingH(i) +SVR.Epsilon) / RemainingGamma(i);
                elseif (RemainingH(i) > -SVR.Epsilon)
                    Lr(i) = (-RemainingH(i) -SVR.Epsilon) / RemainingGamma(i);
                else
                    Lr(i) = q*inf;
                end
            end
        end        
    else
        Lr = q*inf;
    end

    % Check NaN
    Lr(isnan(Lr)) = q*inf;
    
    % Check Sign
    if (any(SIGN(SVR, Lr)==-SIGN(SVR, q) & Lr~=0))
        save 'Error' 'SVR';
        error('sign lr not valid');
    end
    
end
