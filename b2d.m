function [ string ] = b2d( sequence )
% B2D Convertit une sequence de bit sous forme de vecteur ligne 
%     en une chaine de caractere

string = sprintf('%d', sequence);
string = bin2dec(string);

end
