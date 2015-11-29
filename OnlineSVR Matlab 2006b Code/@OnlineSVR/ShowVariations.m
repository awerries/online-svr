%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Show OnlineSVR's Variations

function [] = ShowVariations (SVR, CIndex, H, Beta, Gamma, Lc1, Lc2, Ls, Le, Lr)

    ShowDetails(SVR, CIndex, H);
    
    ShowMessage(SVR, '----- VARIATIONS --------------------------------------------------------------------------------------------------------------------',3);    
    ShowMessage(SVR, '-------------------------------------------------------------------------------------------------------------------------------------',3);
    Message = sprintf('  ELEMENT \t\tWEIGHTS/H\t\t\t\t\t\t\t\t\tBETA/GAMMA\t\t\t\t\t\t\t\tVARIATION');
    ShowMessage(SVR, Message,3);    
    Message = sprintf('> LC1\t%d\t\t%.30f\t\t%.30f\t\t%.30f',CIndex,H(CIndex),Gamma(CIndex),Lc1);    
    ShowMessage(SVR, Message,3);
    Message = sprintf('> LC2\t%d\t\t%.30f\t\t%.30f\t\t%.30f',CIndex,SVR.Weights(CIndex),0,Lc2);
    ShowMessage(SVR, Message,3);
    for i=1:SupportSetElementsNumber(SVR)
        Message = sprintf('> LS%d\t%d\t\t%.30f\t\t%.30f\t\t%.30f',i,SVR.SupportSetIndexes(i),SVR.Weights(SVR.SupportSetIndexes(i)),Beta(i+1),Ls(i));
        ShowMessage(SVR, Message,3);        
    end
    for i=1:ErrorSetElementsNumber(SVR)
        Message = sprintf('> LE%d\t%d\t\t%.30f\t\t%.30f\t\t%.30f',i,SVR.ErrorSetIndexes(i),H(SVR.ErrorSetIndexes(i)),Gamma(SVR.ErrorSetIndexes(i)),Le(i));
        ShowMessage(SVR, Message,3);        
    end
    for i=1:RemainingSetElementsNumber(SVR)
        Message = sprintf('> LR%d\t%d\t\t%.30f\t\t%.30f\t\t%.30f',i,SVR.RemainingSetIndexes(i),H(SVR.RemainingSetIndexes(i)),Gamma(SVR.RemainingSetIndexes(i)),Lr(i));
        ShowMessage(SVR, Message,3);        
    end
    if (length(Beta)>0)
        Message = sprintf('  TOTAL BETA:\t\t\t\t\t\t\t\t\t\t\t%.30f',sum(Beta(2:size(Beta,1))));
    else
        Message = sprintf('  TOTAL BETA:\t\t\t\t\t\t\t\t\t\t\t%.30f',0);
    end
    ShowMessage(SVR, Message,3);
    ShowMessage(SVR, '-------------------------------------------------------------------------------------------------------------------------------------',3);

end