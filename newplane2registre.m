function [ registre index ] = newplane2registre( old_registre, AA )
% bit2registre Renseigne une nouvelle adresse OACI dans le registre 
%              et prepare les vecteurs des registres.

index = length(old_registre.adresse) +1;
registre.adresse =  [old_registre.adresse AA];
registre.format = [old_registre.format 0];
registre.nom =  [old_registre.nom {''}];
registre.latitude = [old_registre.latitude 0];
registre.timeFlag = [old_registre.timeFlag 0];
registre.cprFlag = [old_registre.cprFlag 0];
registre.velocity = [old_registre.velocity 0];
registre.type = [old_registre.type 0];



end