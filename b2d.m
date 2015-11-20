function [ string ] = b2d( sequence )
% b2d Convertit une sequence de bit sous forme de vecteur ligne 
%     en une chaine de caractere

% TO CHECK : performances des differentes methodes 
% num2str( sequence ,'%d')
% char(sequence + '0')

string = sprintf('%d', sequence);
string = bin2dec(string);

end
