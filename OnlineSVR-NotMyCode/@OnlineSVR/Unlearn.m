%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Unlearning of a sample 

function [SVR, Flops] = Unlearn (SVR, CIndex) 
    
    % Inizialization
    Error = SVR.Epsilon / 10;
    Flops = 0;
    
    % CASE 0: Right classified sample
    if (any(find(SVR.RemainingSetIndexes==CIndex)))
        ShowMessage(SVR, '> Case 0: the sample was removed from the remaining set.',2);
        RIndex = find(SVR.RemainingSetIndexes==CIndex);
        SVR.RemainingSetIndexes = [SVR.RemainingSetIndexes(1:(RIndex-1),1); SVR.RemainingSetIndexes((RIndex+1):RemainingSetElementsNumber(SVR),1)];
        SVR.X = [SVR.X(1:(CIndex-1),:); SVR.X((CIndex+1):SVR.SamplesTrainedNumber,:)];
        SVR.Y = [SVR.Y(1:(CIndex-1),1); SVR.Y((CIndex+1):SVR.SamplesTrainedNumber,1)];
        SVR.Weights = [SVR.Weights(1:(CIndex-1),1); SVR.Weights((CIndex+1):SVR.SamplesTrainedNumber,1)];
        SVR.SupportSetIndexes(SVR.SupportSetIndexes>CIndex) = SVR.SupportSetIndexes(SVR.SupportSetIndexes>CIndex)-1;
        SVR.ErrorSetIndexes(SVR.ErrorSetIndexes>CIndex) = SVR.ErrorSetIndexes(SVR.ErrorSetIndexes>CIndex)-1;
        SVR.RemainingSetIndexes(SVR.RemainingSetIndexes>CIndex) = SVR.RemainingSetIndexes(SVR.RemainingSetIndexes>CIndex)-1;
        SVR.SamplesTrainedNumber = SVR.SamplesTrainedNumber - 1;
        if (SVR.SamplesTrainedNumber==0)
            SVR.Bias = 0;
        end
        return;

    % Remove the sample from its set
    else
         % Error Set
        if (any(find(SVR.ErrorSetIndexes==CIndex)))
            EIndex = find(SVR.ErrorSetIndexes==CIndex);
            SVR.ErrorSetIndexes = [SVR.ErrorSetIndexes(1:(EIndex-1),1); SVR.ErrorSetIndexes((EIndex+1):ErrorSetElementsNumber(SVR),1)];
        % SupportSet
        else
            SIndex = find(SVR.SupportSetIndexes==CIndex);
            SVR.SupportSetIndexes = [SVR.SupportSetIndexes(1:(SIndex-1),1); SVR.SupportSetIndexes((SIndex+1):SupportSetElementsNumber(SVR),1)];
            SVR.R = RemoveSampleFromR(SVR, SIndex);
        end
    end
    
    % Inizializations
    Flag = -1;
    nIterations = 0;
    SampleRemoved = 0;
    
    % Find the initial margin
    H = Margin(SVR, SVR.X, SVR.Y);
    
    while (~SampleRemoved)
        
        % Iteration Count
        Flops = Flops + 1;                
        if (Flops > (SVR.SamplesTrainedNumber+1)*100)
            SVR.Verbosity = 3;
            ShowDetails(SVR, CIndex, H);
            save 'Error' 'SVR';
            error('Loop Found. ');
        end

        % Find Beta and Gamma
        [Beta, Gamma] = FindBetaAndGamma(SVR, CIndex);
        
        % Find the samples variations
        [Lc, Ls, Le, Lr] = FindUnlearningMinVariation (SVR, H, Beta, Gamma, CIndex);
        ShowVariations(SVR, CIndex, H, Beta, Gamma, Lc, Lc, Ls, Le, Lr);
        
        % Find the minimum variation
        [MinLs, MinLsIndex] = min (abs(Ls)',[],1);
        [MinLe, MinLeIndex] = min (abs(Le)',[],1);
        [MinLr, MinLrIndex] = min (abs(Lr)',[],1);  
        [MinValue, Flag] = min ([abs(Lc); abs(MinLs); abs(MinLe); abs(MinLr)],[],1);
        if (MinValue==inf)
            error('No weights to modify!',3); 
        end
        switch (Flag)
            case 1
                MinValueWithSign = Lc;
            case 2
                MinValueWithSign = Ls(MinLsIndex);
            case 3
                MinValueWithSign = Le(MinLeIndex);
            case 4
                MinValueWithSign = Lr(MinLrIndex);
        end

        % Find the new variation        
        DeltaC = MinValueWithSign;
        
        % Update Weights and Bias
        if (SupportSetElementsNumber(SVR)>0)
            SVR.Weights(CIndex) = SVR.Weights(CIndex) + DeltaC;
            Delta = Beta*DeltaC;
            SVR.Bias = SVR.Bias + Delta(1);
            SVR.Weights(SVR.SupportSetIndexes) = SVR.Weights(SVR.SupportSetIndexes) + Delta(2:length(Delta));
            H = H + Gamma*DeltaC;
        else            
            SVR.Bias = SVR.Bias + DeltaC;
            H = H + DeltaC;
        end
        
        switch (Flag)
            case 1
                % The sample alpha reaches 0 
                ShowMessage(SVR, '> Case 1: the sample alpha becomes 0', 2);
                SVR.X = [SVR.X(1:(CIndex-1),:); SVR.X((CIndex+1):SVR.SamplesTrainedNumber,:)];
                SVR.Y = [SVR.Y(1:(CIndex-1),1); SVR.Y((CIndex+1):SVR.SamplesTrainedNumber,1)];
                SVR.Weights = [SVR.Weights(1:(CIndex-1),1); SVR.Weights((CIndex+1):SVR.SamplesTrainedNumber,1)];
                H = [H(1:(CIndex-1),1); H((CIndex+1):SVR.SamplesTrainedNumber,1)];
                SVR.SupportSetIndexes(SVR.SupportSetIndexes>CIndex) = SVR.SupportSetIndexes(SVR.SupportSetIndexes>CIndex)-1;
                SVR.ErrorSetIndexes(SVR.ErrorSetIndexes>CIndex) = SVR.ErrorSetIndexes(SVR.ErrorSetIndexes>CIndex)-1;
                SVR.RemainingSetIndexes(SVR.RemainingSetIndexes>CIndex) = SVR.RemainingSetIndexes(SVR.RemainingSetIndexes>CIndex)-1;
                SVR.SamplesTrainedNumber = SVR.SamplesTrainedNumber - 1;
                if (SVR.SamplesTrainedNumber==1 & ErrorSetElementsNumber(SVR)>0)
                    SVR.ErrorSetIndexes = [];
                    SVR.RemainingSetIndexes = [1];
                    SVR.Weights(1) = 0;
                    SVR.Bias = Margin(SVR, SVR.X(1,:),SVR.Y(1));
                    H(1) = 0;
                end                
                if (SVR.SamplesTrainedNumber==0)
                    SVR.Bias = 0;
                end
                SampleRemoved = 1;

            case 2
                % Move Sample from SupportSet to ErrorSet or RemainingSet
                WeightsValue = SVR.Weights(SVR.SupportSetIndexes(MinLsIndex));
                if (abs(WeightsValue)<abs(SVR.C-abs(WeightsValue)))
                    SVR.Weights(SVR.SupportSetIndexes(MinLsIndex)) = 0;
                else
                    SVR.Weights(SVR.SupportSetIndexes(MinLsIndex)) = sign(SVR.Weights(SVR.SupportSetIndexes(MinLsIndex)))*SVR.C;
                end
                SIndex = MinLsIndex;
                if (SVR.Weights(SVR.SupportSetIndexes(MinLsIndex))==0)
                    % Move Sample from SupportSet to RemainingSet
                    ShowMessage(SVR, ['> Case 3a: move sample ' num2str(SVR.SupportSetIndexes(MinLsIndex)) ' from support to remaining set' '     (Var=' num2str(DeltaC) ')'],2);
                    SVR.RemainingSetIndexes(RemainingSetElementsNumber(SVR)+1,1) = SVR.SupportSetIndexes(MinLsIndex,1);
                    SVR.SupportSetIndexes = [SVR.SupportSetIndexes(1:(MinLsIndex-1),1); SVR.SupportSetIndexes((MinLsIndex+1):SupportSetElementsNumber(SVR),1)];
                    SVR.R = RemoveSampleFromR(SVR, SIndex);
                elseif (abs(SVR.Weights(SVR.SupportSetIndexes(MinLsIndex)))== SVR.C) 
                    % Move Sample from SupportSet to ErrorSet
                    ShowMessage(SVR, ['> Case 3b: move sample ' num2str(SVR.SupportSetIndexes(MinLsIndex)) ' from support to error set' '     (Var=' num2str(DeltaC) ')'],2);                                        
                    SVR.ErrorSetIndexes(ErrorSetElementsNumber(SVR)+1,1) = SVR.SupportSetIndexes(MinLsIndex,1);
                    SVR.SupportSetIndexes = [SVR.SupportSetIndexes(1:(MinLsIndex-1),1); SVR.SupportSetIndexes((MinLsIndex+1):SupportSetElementsNumber(SVR),1)];
                    SVR.R = RemoveSampleFromR(SVR, SIndex);
                else
                    SVR.Weights(SVR.SupportSetIndexes(MinLsIndex))
                    error('Not allowed to enter here.');
                end

            case 3
                % Move a sample from error or remaining to support set
                ShowMessage(SVR, ['> Case 4: move sample ' num2str(SVR.ErrorSetIndexes(MinLeIndex)) ' from error to support set' '     (Var=' num2str(DeltaC) ')'],2);                
                EIndex = SVR.ErrorSetIndexes(MinLeIndex);
                H(SVR.ErrorSetIndexes(MinLeIndex),1) = sign(H(SVR.ErrorSetIndexes(MinLeIndex),1))*SVR.Epsilon;                
                SVR.SupportSetIndexes(SupportSetElementsNumber(SVR)+1,1) = SVR.ErrorSetIndexes(MinLeIndex,1);
                SVR.ErrorSetIndexes = [SVR.ErrorSetIndexes(1:(MinLeIndex-1),1); SVR.ErrorSetIndexes((MinLeIndex+1):ErrorSetElementsNumber(SVR),1)];
                SVR.R = AddSampleToR(SVR, EIndex,'ErrorSet',Beta,Gamma);

            case 4
                % Move Sample from RemainingSet to SupportSet
                ShowMessage(SVR, ['> Case 5: move sample ' num2str(SVR.RemainingSetIndexes(MinLrIndex)) ' from remaining to support set' '     (Var=' num2str(DeltaC) ')'],2);
                RIndex = SVR.RemainingSetIndexes(MinLrIndex);                
                H(SVR.RemainingSetIndexes(MinLrIndex),1) = sign(H(SVR.RemainingSetIndexes(MinLrIndex)))*SVR.Epsilon;
                SVR.SupportSetIndexes(SupportSetElementsNumber(SVR)+1,1) = SVR.RemainingSetIndexes(MinLrIndex,1);
                SVR.RemainingSetIndexes = [SVR.RemainingSetIndexes(1:(MinLrIndex-1),1); SVR.RemainingSetIndexes((MinLrIndex+1):RemainingSetElementsNumber(SVR),1)];
                SVR.R = AddSampleToR(SVR, RIndex,'RemainingSet',Beta,Gamma); 
        end
        
        % Show the plot
        if (SVR.MakeVideo)
            SVR = BuildPlot(SVR);
        end

    end

end