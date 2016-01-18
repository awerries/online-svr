%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Length of the ErrorSet

function [x] = ErrorSetElementsNumber (SVR)
    x = length(SVR.ErrorSetIndexes);
end
