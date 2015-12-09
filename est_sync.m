function [ dec_t_est dec_f_est ] = est_sync( yl, preambule, dec_max, Te )
%EST_SYNC Estimation des decalages temporel et frequentiel
%   yl : signal avant le passage dans le filtre adapte
%   preambule : signal correspondant au preambule
%   Te : temps d'echantillonnage

dec_t_max = dec_max(1);
dec_f_max = dec_max(2);
Tp = length(preambule);

% Initialisation :
corr = zeros(dec_f_max * 2 +1, length(yl) - Tp);

t = 0:Te:Te*length(yl)-Te;

% Premiere boucle : boucle d'estimation frequentielle
% for dec_f = -dec_f_max : dec_f_max
%TODELETE
dec_f = 0;
    
    % Correlation (numerateur de l'equation)
    numerateur_compl = xcorr(yl .* exp(j * 2 * pi * dec_f * t), preambule);
    numerateur = numerateur_compl(length(yl):end-Tp);
    
    % Denominateur :
    Eg_sp = sum(abs(preambule).^2);
    
    Egs_yl = zeros(1, length(yl) - Tp);
    for dec_t = 0 : length(yl) - Tp -1
        Egs_yl(dec_t+1) = sum(abs(yl(dec_t+1:dec_t+1+Tp)).^2);
    end
    
    denominateur = sqrt(Eg_sp) * sqrt(Egs_yl);
    
    corr(dec_f + dec_f_max +1, :) = numerateur ./ denominateur;
    
% end

% http://www.mathworks.com/matlabcentral/newsreader/view_thread/298526

[val, ind] = max(corr(:));

[lig, col] = ind2sub(size(corr), ind);

dec_f_est = lig - dec_f_max - 1;
dec_t_est = col - 1;

end

