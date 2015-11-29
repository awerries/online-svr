%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Sign function

function [x] = INDEXOF (SVR, X, Y)
    
    W = size(X,1);
    H = size(X,2);
    
    for i=1:W
        if (sum(X(i,:)==Y)==H)
            x = i;
            return;
        end
    end
    
    x = -1;
end