%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Train the SVR with new data

function [SVR] = WarmTrain (SVR, NewSamplesX, NewSamplesY)    
    
    % Training    
    
    % Parameters
    C = SVR.C;
    Epsilon = SVR.Epsilon;
    KernelType = SVR.KernelType;
    KernelParam = SVR.KernelParam;
    switch upper(KernelType)
        case 'LINEAR'
            KernelValue = '0';
        case 'POLYNOMIAL'
            KernelValue = ['1 -g 1 -r 0 -d ' num2str(KernelParam)];
        case 'RBF'
            KernelValue = ['2 -g ' num2str(KernelParam)]; 
        otherwise
            KernelValue = 0;
    end

    % Train
    Params = ['-s 3' ' -t ' num2str(KernelValue) ' -c ' num2str(C) ' -p ' num2str(Epsilon)];
    ris = svrtrain (NewSamplesY, NewSamplesX, Params);
    
    % Save Results
    SVR.SamplesTrainedNumber = size(NewSamplesX,1);
    SVR.X = NewSamplesX;
    SVR.Y = NewSamplesY;
    SVR.SupportSetIndexes = [];
    SVR.ErrorSetIndexes = [];
    SVR.RemainingSetIndexes = [];
    for i=1:SVR.SamplesTrainedNumber
        index = [];
        for j=1:size(ris.SVs,1)
            if (sum(SVR.X(i,:)==ris.SVs(j,:))==size(SVR.X,2))
                index = j;
                break;
            end
        end
        if (length(index)==0)
            SVR.RemainingSetIndexes = [SVR.RemainingSetIndexes; i];
            SVR.Weights(i,1) = 0;
        elseif (abs(ris.sv_coef(index))==SVR.C)
            SVR.ErrorSetIndexes = [SVR.ErrorSetIndexes; i];
            SVR.Weights(i,1) = ris.sv_coef(index);
        else
            SVR.SupportSetIndexes = [SVR.SupportSetIndexes; i];
            SVR.Weights(i,1) = ris.sv_coef(index);            
        end
    end
    SVR.Bias = -ris.rho;
end
