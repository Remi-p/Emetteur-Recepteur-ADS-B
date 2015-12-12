function [ decalages ] = indices_fin_preamb( yl, preambule, Te, seuil )
%INDICES_FIN_PREAMB Estime la position en terme d'indices de la fin des
%                   preambule dans le buffer
%   yl : signal avant le passage dans le filtre adapte (buffer)
%   preambule : signal correspondant au preambule recherche
%   Te : temps d'echantillonnage
%   seuil : seuil pour le test de valeur a conserver

% => Voir est_sync.m

Tp = length(preambule);

% Correlation (numerateur de l'equation)
numerateur_compl = xcorr(yl, preambule);
numerateur = numerateur_compl( length(yl):end - Tp );
% OPTI

% Denominateur :
Eg_sp = sum(abs(preambule).^2);

Egs_yl = zeros(1, length(yl) - Tp);
for dec_t = 0 : length(yl) - Tp -  1
    Egs_yl(dec_t+1) = sum(abs(yl(dec_t+1:dec_t+1+Tp)).^2);
end

denominateur = sqrt(Eg_sp) * sqrt(Egs_yl);

corr_t = numerateur ./ denominateur;

% Estimation de tous les indices de fin de preambule

indices_corr = 1:length(corr_t);

indices = indices_corr(corr_t > seuil);

decalages = indices + length(preambule) - 1;

end

