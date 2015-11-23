function [ velocity ] = decode_velocity( sequence )
% decode_velocity Decode la valeur de la vitesse a partir de la sequence
%                 issue d'un message de vitesse

Vew = sequence(2:11, 1);
Sew = sequence(1,1);

Vns = sequence(13:21, 1);
Sns = sequence(12,1);

% On prend en compte le bit de signe
if Sew == 1
    Vew = -1*Vew
    
if Sns == 1
    Vns = -1*Vns

% Calcul de la vitesse en (kn -> kilo noeuds)
 velocity = sqrt(Vew^2 + Vns^2);
   
end

