function [ string ] = decode_name( sequence )
% DECODE_NAME Convertit une sequence de bit sous forme de vecteur ligne 
%             en une chaine de caractere en utilisant la table des
%             caracteres utilise par ADS-B

% Inpsire de : http://adsb-decode-guide.readthedocs.org/en/latest/decoding.html

% Ecriture du tableaux
% Chaque case vide est represente par un #
table = '#ABCDEFGHIJKLMNOPQRSTUVWXYZ#####_###############0123456789######';

name = '';
name = strcat(name, table(bin2dec(sequence(1,1:6))+1));
name = strcat(name, table(bin2dec(sequence(1,7:12))+1));
name = strcat(name, table(bin2dec(sequence(1,13:18))+1));
name = strcat(name, table(bin2dec(sequence(1,19:24))+1));
name = strcat(name, table(bin2dec(sequence(1,25:30))+1));
name = strcat(name, table(bin2dec(sequence(1,31:36))+1));
name = strcat(name, table(bin2dec(sequence(1,37:42))+1));
name = strcat(name, table(bin2dec(sequence(1,43:48))+1));

% On enleve les espace et diese eventuels
name = strrep(name, '_', '');
name = strrep(name, '#', '');
string = name;

end
