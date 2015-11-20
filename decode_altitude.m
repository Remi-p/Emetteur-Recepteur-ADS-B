function [ altitude ] = decode_altitude( sequence )
% decode_altitude Decode la valeur de l'altitude exprimee en pieds a partir
%                 de la sequence de bit passee en entree

sequence = [ sequence(1,1:7),sequence(1,9:12) ];

ra = b2d(sequence);

altitude = (25 * ra) - 1000


end

