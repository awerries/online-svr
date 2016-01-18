%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Sign function

function [x] = CONTAINS (SVR, X, Y)
    
    W = size(X,1);
    H = size(X,2);
    
    for i=1:W
        if (sum(W(i,:)==Y)==H)
            x = true;
            return;
        end
    end
    
    x = false;
end