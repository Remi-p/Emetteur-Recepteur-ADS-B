%% =================== Communications numeriques ==================== %%
%  Gourdel Thibaut                                           . \|/ /,  %
%  Perrot Remi          =======================              \\`''/_-- %
%  TS226                | 4.4 Synchronisation |       Bordeaux INP --- %
%  Decembre 2015        |  temps/frequence    |       ENSEIRB  ,..\\`  %
%                       =======================       MATMECA / | \\`  %
% ==================================================================== %

close all;clear all;clc;

%% ================== Initialisation des variables =================== %

% Frequence/periode d'echantillonnage
fe = 20E6;
Te = 1/fe;

% Debit : symboles/s
Ds = 1E6;
% Periode symbole :
Ts = 1/Ds;

% Nombre de symboles
M = 2;

% Probabilite (bk = 0) et (bk = 1)
P = 1/2;

% Nombre de symboles a emettre
Ns = 112;

% Taille d'un buffer
buff = 150;

% Facteur de sur-echantillonnage
Fse = Ts/Te;

% p(t) le filtre de mise en forme
p = [ -ones(1, Fse/2) ones(1, Fse/2) ]/2;
p = p / norm(p);
% p = [ -ones(1, Fse/2) ones(1, Fse/2) ] /2;

% h(t) le filtre du canal
h = ones(1, 1);

% Filtre de reception : Pour maximiser le rapport signal sur bruit,
% on prend pa(t) = p*(-t)
pa = fliplr(p);

% Interval des decalages temporels et frequentiels
dec_t_max = 100;
dec_f_max = 1e3;

% Le preambule correspond au signal donne dans l'enonce. Il n'a pas de lien
% avec la visualisation en termes de bits, meme si on le code avec eux
preamb_faux_bits = [ 1 0 1 0 0 0 0 1 0 1 0 0 0 0 0 0 ];
% Temps entre chaque 'faux' bits ci-dessus / Temps symbole
frac_tps_symb = 0.5e-6 / Ts ;
preamb_upsample = upsample(preamb_faux_bits, Fse * frac_tps_symb);
% Soit :
preambule_tmp = conv(preamb_upsample, ones(1, Fse * frac_tps_symb));
% Vis a vis de la convolution, pour retomber sur le signal qu'on cherche
preambule = preambule_tmp(1:end - Fse*frac_tps_symb + 1);

% -------------------------------Initialisation liees au calcul du TEB %

% Eb/N0 est etendu de 0 a 10 dB, avec un pas de 1

% SNR = 10.^((0:1:10)/10);
% On utilise pas 'SNR' => trop de definitions differentes existent
EbN0dB = 0:1:10;
EbN0 = 10.^(EbN0dB/10);

% (En enlevant 0.5 apres le passage du canal, on est face a un BPSK)
% Pour un BPSK, on a sigma_a^2 = E[|A_k|^2] - |E[Ak]|^2 = 1
% Puisque E[A_k] = 0 / A_k => -1 ou +1 avec meme proba; E[|a_K|^2] = 1
sigma_a_2 = 1;

Eg = sum(abs(p).^2);

% Puisque Eb/N0 = sigma_a^2 * Eg / 2 sigma^2
sigma = sqrt((sigma_a_2 * Eg)./(2*EbN0));

%% =============== Calcul du taux d'erreur binaire =================== %

Teb = zeros(1, length(sigma));

for i=1:length(sigma)
% sigma(end+1) = 0;
% i = length(sigma);

    nb_erreurs = 0;
    k = 0;

    while nb_erreurs < 100

        k = k+1;
        if (mod(k, 100) == 0)
            fprintf('i=%i : iteration #%i, %i erreurs \n', i, k, nb_erreurs);
        end

        % Generation des decalages
        delta_t = randi(dec_t_max);
        delta_f = randi([-dec_f_max dec_f_max]);

        % Generation des bits d'informations
        sb = randi([0, 1], 1, Ns);
        
        % Passage dans le systeme, en bande de base, avec decalage. La
        % gestion du preambule + detection se fait dans la fonction
        s = bdb_sync( sb, sigma(i), Ts, Te, p, h, pa, Ns, 0.5, ...
            preambule, [delta_t, delta_f], [dec_t_max, dec_f_max], buff );
        
        erreurs = sum(abs(sb - s));
        
        nb_erreurs = nb_erreurs + erreurs;
        
    end
    
    Teb(i) = nb_erreurs / (k * length(s));
    
end

%% ==================== Resultats / Figures ========================== %

% Evolution theorique du TEB, calculee en question 10
theorie = erfc(sqrt(EbN0))/2;

% Ligne => TEB = 10^-3
TEB_fixe = ones(1, length(EbN0dB)) * 10^-3;

semilogy(EbN0dB, theorie, EbN0dB, Teb, EbN0dB, TEB_fixe);

xlabel('Eb/N0 (dB)');
ylabel('TEB');
title('TEB en fonction de EbN0');
legend('TEB Theorique', 'TEB Pratique', '10^-^3');
