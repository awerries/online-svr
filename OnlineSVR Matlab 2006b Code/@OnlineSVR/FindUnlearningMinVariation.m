%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Find the variations of each sample to a new set
%
% Lc: distance of the old sample to the RemainingSet (unlearning only)
% Ls(i): distance of the support samples to the ErrorSet/RemainingSet
% Le(i): distance of the error samples to the SupportSet
% Lr(i): distance of the remaining samples to the SupportSet

function [Lc, Ls, Le, Lr] = FindUnlearningMinVariation (SVR, H, Beta, Gamma, CIndex)

    % Find the direction q of the new sample 
    warning off;    
    q = -SIGN(SVR, SVR.Weights(CIndex));
   
    % Find Variations
    Lc = FindVariationLc(SVR, CIndex);
    Ls = FindVariationsLs(SVR, Beta, q, H);
    Le = FindVariationsLe(SVR, H, Gamma, q);
    Lr = FindVariationsLr(SVR, H, Gamma, q);
    
   % Check if there are more minimum values, than get the one with maximum gamma/beta
   % SupportSet
   [MinS IndexS] = min(abs(Ls),[],1);
   Results = find(abs(Ls)==MinS);
   if (Results>1)
       [BetaMax, BetaIndex] = max(SVR.Beta(Results+1),[],1);
       Ls(Results) = q*inf;
       Ls(BetaIndex) = q*MinS;
   end   
   % ErrorSet
   [MinE IndexE] = min(abs(Le),[],1);
   Results = find(abs(Le)==MinE);
   if (Results>1)
       ErrorGamma = Gamma(SVR.ErrorSetIndexes);
       [GammaMax, GammaIndex] = max(ErrorGamma(Results),[],1);
       Le(Results) = q*inf;
       Le(GammaIndex) = q*MinE;
   end    
   % RemainingSet
   [MinR IndexR] = min(abs(Lr),[],1);
   Results = find(abs(Lr)==MinR);
   if (Results>1)
       RemainingGamma = Gamma(SVR.RemainingSetIndexes);
       [GammaMax, GammaIndex] = max(RemainingGamma(Results),[],1);
       Lr(Results) = q*inf;
       Lr(GammaIndex) = q*MinR;
   end
    
   warning on;
    
end
