function [ decalages ] = indices_fin_preamb( yl, preambule, lg_trame_canal, Te, seuil )
%INDICES_FIN_PREAMB Estime la position en terme d'indices de la fin des
%                   preambule dans le buffer
%   yl : signal avant le passage dans le filtre adapte (buffer)
%   preambule : signal correspondant au preambule recherche
%   lg_trame_canal : longueur de la trame (permet de ne pas calculer des
%                    valeurs inutiles)
%   Te : temps d'echantillonnage
%   seuil : seuil pour le test de valeur a conserver
% 
% Remarque : version optimisee pour le temps reel, qui ne prends donc pas
%            en compte le decalage frequentiel (annule par le module).
%            => Voir est_sync.m pour l'estimation temporelle+frequentielle

Tp = length(preambule);

% Inutile de regarder a la fin du buffer?
yl_studied = yl(1:end-lg_trame_canal);

% Correlation ------------------------------------------------ Numerateur
% numerateur_compl = xcorr(yl, preambule);
% numerateur = numerateur_compl( length(yl):end - lg_trame_canal );
% On va plutot utiliser la convolution, plus rapide que xcorr, qui prend
% plus de 85% du temps de notre fonction.
numerateur = conv(yl_studied, fliplr(preambule), 'valid');
% ('valid 'permet de ne pas prendre en compte l'ajout de 0 pr la conv)

% ----------------------------------------------------------- Denominateur
Eg_sp = sum(abs(preambule).^2);

% Egs_yl = zeros(1, length(yl) - lg_trame_canal);
% for dec_t = 0 : length(yl) - lg_trame_canal - 1
%     Egs_yl(dec_t+1) = sum(abs(yl(dec_t+1:dec_t+1+Tp)).^2);
% end
% De meme, pour augmenter les performances, il est possible de reecrire la
% fonction precedente sous forme de convolution (puisque c'est une somme
% qui se "deplace") :

% La somme est caracterisee par le nombre de 1 du ones
% Egs_yl = conv(abs(yl_studied.^2), ones(1, Tp), 'valid');

% On est deja face au module de yl. Donc finalement :
Egs_yl = conv(yl_studied.^2, ones(1, Tp), 'valid');

denominateur = sqrt(Eg_sp) * sqrt(Egs_yl);

corr_t = numerateur ./ denominateur;

% Estimation de toutes les positions du preambule

indices_corr = 1:length(corr_t);

indices = indices_corr(corr_t > seuil);

% On met nos positions a la fin de chaque preambule
decalages = indices + Tp - 1;

% Remarque : en utilisant des convolutions, plutot qu'une correlation et
%            une boucle, on passe - pour un buffer de 0.5 seconde - de 10s
%            d'execution, a ~0.3s.

% plot(corr_t);
% pause;

end

