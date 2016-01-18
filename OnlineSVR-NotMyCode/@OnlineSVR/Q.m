%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Find the Q matrix

function [Qnew] = Q (SVR, Set1, Set2)
    
    % Inizialization
    Qnew = [];
    nSet1 = size(Set1,1);
    nSet2 = size(Set2,1);
    
    % Find Q
    for i=1:nSet1
        for j=1:nSet2
            Qnew(i,j) = Kernel(SVR, Set1(i,:),Set2(j,:));
        end
    end
    
end