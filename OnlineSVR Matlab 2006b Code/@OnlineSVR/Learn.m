%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Learning of a new sample 

function [SVR, Flops] = Learn (SVR, NewSampleX, NewSampleY)

    % Inizialization    
    SVR.SamplesTrainedNumber = SVR.SamplesTrainedNumber +1;
    CIndex = SVR.SamplesTrainedNumber;
    SVR.X(CIndex,:) = NewSampleX;
    SVR.Y(CIndex,1) = NewSampleY;
    SVR.Weights(CIndex,1) = 0;
    H = Margin(SVR, SVR.X, SVR.Y);
    Error = SVR.Epsilon/10;
    Flops = 0;
    
    % CASE 0: Right classified sample
    if (abs(H(CIndex)) <= SVR.Epsilon)
        ShowMessage(SVR, '> Case 0: the machine have classified correctly the sample.',2);
        SVR.RemainingSetIndexes(RemainingSetElementsNumber(SVR)+1,1) = CIndex;
        Flops = Flops + 1;
        return;
    end
        
    % Inizializations
    Flag = -1;
    NewSampleAdded = 0;
    
    while (~NewSampleAdded)
        
        % Iteration Count
        Flops = Flops + 1;
        if (Flops > (SVR.SamplesTrainedNumber+1)*100)
            SVR.Verbosity = 3;
            SVR.ShowDetails(CIndex, H);
            save 'Error' 'SVR';
            error('Loop Found. ');
        end

        % Find Beta and Gamma
        [Beta, Gamma] = FindBetaAndGamma(SVR, CIndex);
        
        % Find the samples variations
        [Lc1, Lc2, Ls, Le, Lr] = FindLearningMinVariation (SVR, H, Beta, Gamma, CIndex);
        ShowVariations(SVR, CIndex, H, Beta, Gamma, Lc1, Lc2, Ls, Le, Lr);
        
        % Find the minimum variation
        [MinLs, MinLsIndex] = min (abs(Ls)',[],1);
        [MinLe, MinLeIndex] = min (abs(Le)',[],1);
        [MinLr, MinLrIndex] = min (abs(Lr)',[],1);  
        [MinValue, Flag] = min ([abs(Lc1); abs(Lc2); abs(MinLs); abs(MinLe); abs(MinLr)],[],1);
        if (MinValue==inf)
            error('No weights to modify!',3); 
        end

        switch (Flag)
            case 1
                MinValueWithSign = Lc1;
            case 2
                MinValueWithSign = Lc2;                
            case 3
                MinValueWithSign = Ls(MinLsIndex);
            case 4
                MinValueWithSign = Le(MinLeIndex);
            case 5
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
                % Add NewSample to SupportSet
                ShowMessage(SVR, ['> Case 1: sample ' num2str(CIndex) ' is a support sample'],2);
                H(CIndex) = sign(H(CIndex))*SVR.Epsilon;
                SVR.SupportSetIndexes = [SVR.SupportSetIndexes; CIndex];
                SVR.R = AddSampleToR(SVR, CIndex,'SupportSet',Beta,Gamma);                
                NewSampleAdded = 1;
                
            case 2
                % Add NewSample to ErrorSet
                ShowMessage(SVR, ['> Case 2: sample ' num2str(CIndex) ' is an error sample'],2);
                SVR.Weights(CIndex) = sign(SVR.Weights(CIndex))*SVR.C;
                SVR.ErrorSetIndexes = [SVR.ErrorSetIndexes; CIndex];
                NewSampleAdded = 1;

            case 3
                % Move Sample from SupportSet to ErrorSet or RemainingSet
                WeightsValue = SVR.Weights(SVR.SupportSetIndexes(MinLsIndex));
                if (abs(WeightsValue)<abs(SVR.C-abs(WeightsValue)))
                    SVR.Weights(SVR.SupportSetIndexes(MinLsIndex)) = 0;
                else
                    SVR.Weights(SVR.SupportSetIndexes(MinLsIndex)) = sign(SVR.Weights(SVR.SupportSetIndexes(MinLsIndex)))*SVR.C;
                end
                SIndex = MinLsIndex;
                Index = SVR.SupportSetIndexes(MinLsIndex);
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

            case 4
                % Move a sample from error or remaining to support set
                ShowMessage(SVR, ['> Case 4: move sample ' num2str(SVR.ErrorSetIndexes(MinLeIndex)) ' from error to support set' '     (Var=' num2str(DeltaC) ')'],2);                
                EIndex = SVR.ErrorSetIndexes(MinLeIndex);
                H(SVR.ErrorSetIndexes(MinLeIndex),1) = sign(H(SVR.ErrorSetIndexes(MinLeIndex),1))*SVR.Epsilon;                
                SVR.SupportSetIndexes(SupportSetElementsNumber(SVR)+1,1) = SVR.ErrorSetIndexes(MinLeIndex,1);
                SVR.ErrorSetIndexes = [SVR.ErrorSetIndexes(1:(MinLeIndex-1),1); SVR.ErrorSetIndexes((MinLeIndex+1):ErrorSetElementsNumber(SVR),1)];
                SVR.R = AddSampleToR(SVR, EIndex, 'ErrorSet', Beta, Gamma);

            case 5
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
