%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Kernel Function

function [X] = Kernel (SVR, X1, X2)

    if (size(X1,1)==0)
        X = [];
    else
        switch (upper(SVR.KernelType))
            
            % Linear Kernel
            case 'LINEAR'                
                X = X1*X2';
            
            % Polynomial Kernel
            case 'POLYNOMIAL'
                X = (X1*X2'+1).^SVR.KernelParam;         

            % Radial Basis Function Kernel
            case 'RBF'
                X = exp(-SVR.KernelParam.*(Dist(X1,X2').^2));
           
            % Gaussian Radial Basis Function
            case 'GAUSSIANRBF'
                X = exp(-Dist(X1,X2').^2 / (2*SVR.KernelParam^2));
                
            case 'EXPONENTIALRBF'
                X = exp(-abs(Dist(X1,X2')) / (2*SVR.KernelParam^2));
            
            case 'MLP'
                X = tanh((X1*X2')*SVR.KernelParam+SVR.KernelParam2);
        end
    end
    
end




% Euclidean Distance
function [X] = Dist (X1, X2)
    [S,R] = size(X1);
    [R2,Q] = size(X2);    
    z = zeros(S,Q);
    if (Q<S)
        X2 = X2';
        copies = zeros(1,S);
        for q=1:Q
            X(:,q) = sum((X1-X2(q+copies,:)).^2,2);
        end
    else
        X1 = X1';
        copies = zeros(1,Q);
        for i=1:S
            X(i,:) = sum((X1(:,i+copies)-X2).^2,1);
        end
    end
    X = sqrt(X);
end
