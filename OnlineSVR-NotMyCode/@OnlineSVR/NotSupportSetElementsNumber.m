%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Length of the NotSupportSet

function [x] = NotSupportSetElementsNumber (SVR)
    x = length(SVR.NotSupportSetIndexes);
end
