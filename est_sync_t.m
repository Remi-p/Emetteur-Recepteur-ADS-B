function [ dec_t_est val ] = est_sync_t( yl, preambule, Te )
%EST_SYNC_T Estimation du decalage temporel uniquement
%   yl : signal avant le passage dans le filtre adapte
%   preambule : signal correspondant au preambule recherche
%   Te : temps d'echantillonnage
%   taille_sl : taille du vecteur d'information

% => Voir est_sync.m

Tp = length(preambule);

% Correlation (numerateur de l'equation)
numerateur_compl = xcorr(yl, preambule);
numerateur = numerateur_compl( length(yl):end - Tp );

% Denominateur :
Eg_sp = sum(abs(preambule).^2);

Egs_yl = zeros(1, length(yl) - Tp);
for dec_t = 0 : length(yl) - Tp -  1
    Egs_yl(dec_t+1) = sum(abs(yl(dec_t+1:dec_t+1+Tp)).^2);
end

denominateur = sqrt(Eg_sp) * sqrt(Egs_yl);

corr_t = numerateur ./ denominateur;

% Estimation :
[val, ind] = max(corr_t);
dec_t_est = ind - 1;

val = abs(val);

end

