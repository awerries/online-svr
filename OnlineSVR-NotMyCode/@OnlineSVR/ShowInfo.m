%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Show OnlineSVR's info

function [] = ShowInfo (SVR)
    disp ('----------------------------------------------------');
    disp ('------   ONLINE SVR   ------------------------------');
    disp ('----------------------------------------------------');
    disp (['C: ' num2str(SVR.C)]);
    disp (['Epsilon: ' num2str(SVR.Epsilon)]);
    disp (['KernelType: ' SVR.KernelType]);
    disp (['KernelParam: ' num2str(SVR.KernelParam)]);
    disp (' ');
    disp (['Number of Samples Trained:   ' num2str(SVR.SamplesTrainedNumber)]);
    disp (['> Support Samples:   ' num2str(SupportSetElementsNumber(SVR))]);
    disp (['> Error Samples:     ' num2str(ErrorSetElementsNumber(SVR))]);
    disp (['> Remaining Samples: ' num2str(RemainingSetElementsNumber(SVR))]);
    disp ('----------------------------------------------------');
end