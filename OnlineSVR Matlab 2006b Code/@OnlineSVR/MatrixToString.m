%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ONLINE SUPPORT VECTOR REGRESSION                    %
%                    Copyright 2006 - Francesco Parrella                  %
%                                                                         %
%      This program is distributed under the terms of the GNU License     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Convert a matrix into a string

function [Text] = MatrixToString (SVR, Matrix)

    Text = '';
    if (size(Matrix,1)==0 || size(Matrix,2)==0)
        return;
    end    
    for i=1:size(Matrix,1)
        Text = [Text ' (' num2str(Matrix(i,1))];
        for j=2:size(Matrix,2)
            Text = [Text ',' num2str(Matrix(i,j))];
        end
        Text = [Text ')'];
    end
    
end