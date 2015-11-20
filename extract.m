function [ part ] = extract( sequence, col, l_min, l_max )

    part = transpose(sequence(l_min:l_max, col));

end
