function [ dec_t_est dec_f_est ] = est_sync( yl, preambule, dec_max, Te, taille_sl, Fse )
%EST_SYNC Estimation des decalages temporel et frequentiel
%   yl : signal avant le passage dans le filtre adapte
%   preambule : signal correspondant au preambule
%   Te : temps d'echantillonnage
%   taille_sl : taille du vecteur d'information
%   Fse : facteur de sur-echantillonnage

dec_t_max = dec_max(1);
dec_f_max = dec_max(2);
Tp = length(preambule);


% Le decalage frequentiel n'impacte pas la detection du decalage temporel.
% On separe donc les deux operations !

% ------------------------------------ Decalage temporel

% Correlation (numerateur de l'equation)
numerateur_compl = xcorr(yl, preambule);
numerateur = numerateur_compl(length(yl):end - Tp - taille_sl - Fse);

% Denominateur :
Eg_sp = sum(abs(preambule).^2);

Egs_yl = zeros(1, length(yl) - Tp - taille_sl - Fse);
for dec_t = 0 : length(yl) - Tp - taille_sl - Fse -  1
    Egs_yl(dec_t+1) = sum(abs(yl(dec_t+1:dec_t+1+Tp)).^2);
end

denominateur = sqrt(Eg_sp) * sqrt(Egs_yl);

corr_t = numerateur ./ denominateur;

% Estimation :
[val, ind] = max(corr_t);
dec_t_est = ind - 1;
    
% --------------------------------- Decalage frequentiel
preamb_est =  yl( dec_t_est + 1:dec_t_est + Tp );

t = Te * dec_t_est : Te : Te*(Tp + dec_t_est - 1);

corr_f = zeros(1, 2 * dec_f_max + 1);

% Boucle d'estimation frequentielle
for dec_f = -dec_f_max : dec_f_max
    
    % Seul le numerateur est lie au decalage de frequence. La correlation
    % disparait puisqu'on fixe le decalage t.
    
    corr_f(dec_f + dec_f_max + 1) = ...
        sum( preamb_est .* exp(j * 2 * pi * dec_f * t) .* preambule );

end

% Estimation :
[val, ind] = max(corr_f);
dec_f_est = ind - dec_f_max - 1;

end

