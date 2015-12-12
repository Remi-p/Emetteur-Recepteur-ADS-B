function [ s ] = decod( trame_cod, decalage, ga, Fse )
%DECOD Passe le signal dans la derniere partie de la chaine de
%      communication
%   trame_cod : Trame surechantillonnee

M = 2;

yl = trame_cod;

%% ========================== Recepteur ============================== %

yl_decal = yl - decalage;

% ----------------------- Filtre de reception ------------------------ %
rl = conv(yl_decal, ga, 'same');

% ------------------------- Echantillonnage -------------------------- %
rl_d = rl(1:Fse:end);

ss_sur = zeros(1, length(rl_d)*Fse);
ss_sur(1:Fse:length(rl_d)*Fse) = rl_d;

% plot(rl_d);

% MODIF
% figure;
% hold on;
% plot(rl, 'g');
% stem(ss_sur, 'b');
% pause;
% close;

% -------------------------- Bloc decision --------------------------- %
% ------------------ Bloc association symbole->bits ------------------ %
s = pamdemod(rl_d, M, 0);

end

