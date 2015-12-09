%% =================== Communications numeriques ==================== %%
%  Gourdel Thibaut                                           . \|/ /,  %
%  Perrot Remi            =================                  \\`''/_-- %
%  TS226                  | 4.3 Travail   |           Bordeaux INP --- %
%  Novembre 2015          |  a effectuer  |           ENSEIRB  ,..\\`  %
%                         =================           MATMECA / | \\`  %
% ==================================================================== %

close all
clear all
clc

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

% Frequence porteuse en Hz
f0 = 1090E6;

% Probabilite (bk = 0) et (bk = 1)
P = 1/2;

% Nombre de symbole a emmettre
Ns = 5000;

% Retard lors de l'echantillonnage
retard = 0;

% Facteur de sur-echantillonnage
Fse = Ts/Te;

% Precision pour les transformees de Fourier
N = 512;
% Interval des spectres
Int = [-fe/2, fe/2 - fe/N];

% g(t) le filtre de mise en forme
g = ones(1, (Fse)) * 0.5;
g(Fse/2:Fse) = - g(Fse/2:Fse);

% h(t) le filtre du canal
h = ones(1, 1);

% Filtre de reception : Pour maximiser le rapport signal sur bruit,
% on prend ga(t) = g*(-t)
ga = fliplr(g);

% Precision des dsp
Nfft = 512;

% -------------------------------Initialisation liees au calcul du TEB %
% Nombre d'iteration pour le TEB
iter = 100;

% Eb/N0 est etendu de 0 a 10 dB, avec un pas de 1

% SNR = 10.^((0:1:10)/10);
% On utilise pas 'SNR' => trop de definitions differentes existent
EbN0dB = 0:1:10;
EbN0 = 10.^(EbN0dB/10);

% Pour un BPSK, on a sigma_a^2 = E[|A_k|^2] - |E[Ak]|^2 = 1
% Puisque E[A_k] = 0 / A_k => -1 ou +1 avec meme proba; E[|a_K|^2] = 1
sigma_a_2 = 1;

Eg = sum(abs(g).^2);

% Puisque Eb/N0 = sigma_a^2 * Eg / 2 sigma^2
sigma = sqrt((sigma_a_2 * Eg)./(2*EbN0));

%% =============== Calcul du taux d'erreur binaire =================== %

TEB = zeros(length(sigma), iter);

for i=1:length(sigma)
    
    for j=1:iter
        % Generation des bits d'informations
        sb = randi([0, 1], 1, Ns);
        % Generation du bruit
        nl = 0 + sigma(i)*randn(1, Ts/Te*Ns + Ts/Te - 1);
        
        s = bdb( sb, M, Ts, Te, g, h, nl, ga, Ns, retard );
        
        Teb(i, j) = sum(abs(sb - s)) / length(s);
    end
    
end

%% ==================== Resultats / Figures ========================== %

% Erreurs
Teb = mean(Teb, 2);

% Evolution theorique du TEB
theorie = erfc(sqrt(EbN0))/2;

% Ligne => TEB = 10^-3
TEB_fixe = ones(1, length(EbN0dB)) * 10^-3;

semilogy(EbN0dB, theorie, EbN0dB, Teb, EbN0dB, TEB_fixe);

xlabel('Eb/N0 (dB)');
ylabel('TEB');
title('TEB en fonction de EbN0');
legend('TEB Theorique', 'TEB Pratique', '10^-^3');
