function [ part ] = extract( sequence, col, l_min, l_max )
% EXTRACT Permet d'extraire des bits specifiques d'une trame + transpose

    part = transpose(sequence(l_min:l_max, col));

end
