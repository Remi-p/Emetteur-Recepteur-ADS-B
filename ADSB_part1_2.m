%% =================== Communications numeriques ==================== %%
%  Gourdel Thibaut                                           . \|/ /,  %
%  Perrot Remi            =================                  \\`''/_-- %
%  TS226                  | 4.3 Travail   |           Bordeaux INP --- %
%  Decembre 2015          |  a effectuer  |           ENSEIRB  ,..\\`  %
%                         =================           MATMECA / | \\`  %
% ==================================================================== %

close all;clear all;clc

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

% Nombre de symbole a emettre (=> nombre de bits, puisque M = 2)
Ns = 112;
% Adaptation du code pour l'envoi de paquets de 112

% Facteur de sur-echantillonnage
Fse = Ts/Te;

% p(t) le filtre de mise en forme
p = - ones(1, (Fse)) * 0.5;
p(Fse/2:Fse) = - p(Fse/2:Fse);

% h(t) le filtre du canal
h = ones(1, 1);

% Filtre de reception : Pour maximiser le rapport signal sur bruit,
% on prend pa(t) = p*(-t)
pa = fliplr(p);

% -------------------------------Initialisation liees au calcul du TEB %
% Nombre d'iteration pour le TEB
iter = 200;

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

TEB = zeros(1, length(sigma));

for i=1:length(sigma)
    
    nb_erreurs = 0;
    k = 0;
    
    while nb_erreurs < 100
        
        % Generation des bits d'informations
        sb = randi([0, 1], 1, Ns);
        % Generation du bruit
        nl = 0 + sigma(i)*randn(1, Ts/Te*Ns + Ts/Te - 1);
        
        % Passage dans le systeme, en bande de base
        s = bdb( sb, M, Ts, Te, p, h, nl, pa, Ns, 0, 0.5 );
        
        k = k+1;
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
