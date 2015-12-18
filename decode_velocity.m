function [ velocity, head ] = decode_velocity( sequence )
% DECODE_VELOCITY Decode la valeur de la vitesse a partir de la sequence
%                 issue d'un message de vitesse ainsi que le cap
%   sequence : issue d'une trame de vitesse

Vew = sequence(1, 2:11);
Sew = sequence(1,1);

Vns = sequence(1, 13:21);
Sns = sequence(1,12);

Vew = bin2dec(num2str(Vew));
Vns = bin2dec(num2str(Vns));

% On prend en compte le bit de signe
if Sew == 1
    Vew = -1*Vew;
end
if Sns == 1
    Vns = -1*Vns;
end
% Calcul de la vitesse en (kn -> kilo noeuds)
 velocity = sqrt(Vew^2 + Vns^2);
 
 head = atan(Vew/Vns) * 360/2*pi;
 if head < 0
     head = head +360;
 end
 
end

