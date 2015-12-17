function [ trajectoire ] = newcoordinates( old_trajectoire, coordinates )
% NEWCOORDINATES Ajoute un vecteur contenant l'altitude et la latitude au 
%                tableau de coordonnee de l'attribut trajectoire d'un avion

old_trajectoire(end+1,:) = coordinates;
trajectoire = old_trajectoire

end