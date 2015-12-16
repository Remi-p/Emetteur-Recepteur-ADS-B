function [ s, poids ] = decod( trame_cod, decalage, ga, Fse )
%DECOD Passe le signal dans la derniere partie de la chaine de
%      communication
%   trame_cod : Trame surechantillonnee

M = 2;

yl = trame_cod;

%% ========================== Recepteur ============================== %

yl_decal = yl - decalage;

% ----------------------- Filtre de reception ------------------------ %
rl = conv(yl_decal, ga);

% ------------------------- Echantillonnage -------------------------- %
indices = Fse + (0:Fse:length(yl) - Fse);
rl_d = rl(indices);

display = false;
if display

    ss_sur = zeros(1, length(rl_d)*Fse);
    ss_sur(indices) = rl_d;

    figure;
    hold on;
    plot(rl, 'g');
    stem(ss_sur, 'b');
    pause;
    close;
end

% -------------------------- Bloc decision --------------------------- %
% ------------------ Bloc association symbole->bits ------------------ %
s = pamdemod(rl_d, M, 0);

% Pour la correction, on rajoute le poids des bits par rapport aux autres
poids = abs(rl_d)./sqrt(sum(rl_d.^2));

end

