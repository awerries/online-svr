%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Remove a sample from R Matrix

function [Rnew] = RemoveSampleFromR (SVR, SampleIndex)
            
    % Indexes
    I = [1:(SampleIndex) (SampleIndex+2):(size(SVR.R,1))];    

    % Compute new R
    warning off;
    if (SVR.R(SampleIndex+1,SampleIndex+1)~=0)
        Rnew = SVR.R(I,I) - ((SVR.R(I,SampleIndex+1)*SVR.R(SampleIndex+1,I)) ./ SVR.R(SampleIndex+1,SampleIndex+1));
    else
        Rnew = SVR.R(I,I);
    end
    if (any(any(isnan(Rnew))))
        error('WARNING: R becomes inconsist. Train again the OnlineSVR');
    end
    if (size(Rnew,1)==1)
        Rnew = [];
    end
    warning on;

end