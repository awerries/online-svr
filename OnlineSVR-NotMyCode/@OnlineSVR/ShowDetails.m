%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Show OnlineSVR's Details

function [] = ShowSetsInformations (SVR, CIndex, H)

    if (~exist('H'))
        H = Margin(SVR, SVR.X, SVR.Y);
        Verbosity = SVR.Verbosity;
        SVR.Verbosity = 3;        
    end    
    ShowMessage(SVR, ' ',3);
    ShowMessage(SVR, '------------------------------------------------------------------------------------------',3);
    ShowMessage(SVR, '----- TRAINING SET -----------------------------------------------------------------------',3);
    ShowMessage(SVR, '------------------------------------------------------------------------------------------',3);
    Message = sprintf('  ELEMENT\t\tWEIGHTS\t\t\t\t\t\t\t\t\tH');
	ShowMessage(SVR, Message,3);    
    for i=1:SupportSetElementsNumber(SVR)
        Message = sprintf('> S%d\t%d\t\t%.30f\t\t%.30f',i,SVR.SupportSetIndexes(i),SVR.Weights(SVR.SupportSetIndexes(i)),H(SVR.SupportSetIndexes(i)));
        ShowMessage(SVR, Message,3);
    end
    for i=1:ErrorSetElementsNumber(SVR)
        Message = sprintf('> E%d\t%d\t\t%.30f\t\t%.30f',i,SVR.ErrorSetIndexes(i),SVR.Weights(SVR.ErrorSetIndexes(i)),H(SVR.ErrorSetIndexes(i)));
        ShowMessage(SVR, Message,3);
    end
    for i=1:RemainingSetElementsNumber(SVR)
        Message = sprintf('> R%d\t%d\t\t%.30f\t\t%.30f',i,SVR.RemainingSetIndexes(i),SVR.Weights(SVR.RemainingSetIndexes(i)),H(SVR.RemainingSetIndexes(i)));
        ShowMessage(SVR, Message,3);
    end

    if (exist('CIndex'))
        Message = sprintf('> C \t%d\t\t%.30f\t\t%.30f',CIndex,SVR.Weights(CIndex),H(CIndex));
        ShowMessage(SVR, Message,3);
    end    
    Message = sprintf('  TOTAL\t\t\t%.30f',sum(SVR.Weights));
    ShowMessage(SVR, Message,3);
    ShowMessage(SVR, '------------------------------------------------------------------------------------------',3);

    if (~exist('CIndex'))
        SVR.Verbosity = Verbosity;
    end

end