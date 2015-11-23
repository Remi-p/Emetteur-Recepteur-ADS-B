function [ mod ] = MOD( X, Y )
%MOD 

mod = X - Y*ceil(X/Y);

end

