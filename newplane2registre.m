function [ registre ] = newplane2registre( registre, AA, index )
% NEWPLANE2REGISTRE Renseigne une nouvelle adresse OACI dans le registre 
%                   et prepare les vecteurs des registres.
%   registre : registre qui sera modifie et passe en sortie
%   AA : adresse de l'avion
%   index : index de l'avion dans le registre

registre.adresse(end + 1) =  AA;
registre.format(end + 1) = 0;
registre.nom{end + 1} =  '';
registre.altitude(end + 1) = 0;
registre.positions{index} = [];
registre.timeFlag(end + 1) = 0;
registre.cprFlag(end + 1) = 0;
registre.velocity(end + 1) = 0;
registre.type(end + 1) = 0;
registre.update(end + 1) = 0;
registre.head(end + 1) = 0;
% registre.adresse =  [old_registre.adresse AA];
% registre.format = [old_registre.format 0];
% registre.nom =  [old_registre.nom {''}];
% registre.altitude = [old_registre.altitude 0];
% old_registre.positions{index} = [];
% registre.positions = old_registre.positions;
% registre.timeFlag = [old_registre.timeFlag 0];
% registre.cprFlag = [old_registre.cprFlag 0];
% registre.velocity = [old_registre.velocity 0];
% registre.type = [old_registre.type 0];
% registre.update = [old_registre.update 0];
% registre.head = [old_registre.head 0];

end