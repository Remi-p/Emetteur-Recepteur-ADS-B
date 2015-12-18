function [ part ] = extract( sequence, col, l_min, l_max )
% EXTRACT Permet d'extraire des bits specifiques d'une trame + transpose
% 
% sequence : serie de bits a traiter
% col : colonne de la matrice
% l_min : ligne minimum
% l_max : ligne max

    part = transpose(sequence(l_min:l_max, col));

end
