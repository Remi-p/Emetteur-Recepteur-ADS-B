function [ s ] = decod( trame_cod, decalage, ga, Fse )
%DECOD Passe le signal dans la derniere partie de la chaine de
%      communication
%   trame_uncod : Trame surechantillonnee

M = 2;

yl = abs( trame_cod );

%% ========================== Recepteur ============================== %

% ----------------------- Filtre de reception ------------------------ %
rl = conv(yl - decalage, ga);

% ------------------------- Echantillonnage -------------------------- %
rl_d = rl(1:Fse:end);


% -------------------------- Bloc decision --------------------------- %
% ------------------ Bloc association symbole->bits ------------------ %
s = pamdemod(rl_d, M, 0);

end

