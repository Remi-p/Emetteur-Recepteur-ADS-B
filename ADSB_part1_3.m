%% =================== Communications numeriques ==================== %%
%  Gourdel Thibaut                                           . \|/ /,  %
%  Perrot Remi            =================                  \\`''/_-- %
%  TS226                  |  Partie 1     |           Bordeaux INP --- %
%  Decembre 2015          |  Section 3    |           ENSEIRB  ,..\\`  %
%                         =================           MATMECA / | \\`  %
% ==================================================================== %

close all
clear all
clc

%% Question 14

%% ================== Initialisation des variables =================== %

fe = 20E6; % Frequence d'echantillonnage
Te = 1/fe; % Periode d'echantillonnage
Ds = 1E6; % Debit : symboles/s
Ts = 1/Ds; % Periode symbole :
M = 2; % Nombre de symboles
f0 = 1090E6; % Frequence porteuse en Hz
P = 1/2; % Probabilite (bk = 0) et (bk = 1)
Ns = 5000; % Nombre de symbole a emmettre
retard = 0; % Retard lors de l'echantillonnage
Fse = Ts/Te; % Facteur de sur-echantillonnage
N = 512; % Precision pour les transformees de Fourier

% Interval des spectres
Int = [-fe/2, fe/2 - fe/N];

% g(t) le filtre de mise en forme
g = ones(1, (Fse)) * 0.5; 
g(Fse/2:Fse) = - g(Fse/2:Fse); 
h = ones(1, 1); % h(t) le filtre du canal
ga = fliplr(g); 
Nfft = 512; % Precision des dsp

% Eb/N0 est etendu de 0 a 10 dB, avec un pas de 1
EbN0dB = 0:1:10;
EbN0 = 10.^(EbN0dB/10);

% Pour un BPSK, on a sigma_a^2 = E[|A_k|^2] - |E[Ak]|^2 = 1
% Puisque E[A_k] = 0 / A_k => -1 ou +1 avec meme proba; E[|a_K|^2] = 1
sigma_a_2 = 1;
Eg = sum(abs(g).^2);
% Puisque Eb/N0 = sigma_a^2 * Eg / 2 sigma^2

%%  Generation des decalges temporels et frequentiels
delta_t = randi(100);
delta_f = randi([-1E3 1E3]);

%% =============== Calcul du taux d'erreur binaire =================== %

iter = 100;

TEB = zeros(length(sigma), iter);

for i=1:length(sigma)
    
    for j=1:iter
        % Generation des bits d'informations
        sb = randi([0, 1], 1, Ns);
        % Generation du bruit
        % n_l = sqrt(sigma_n_l)*randn(1,length(s_l_sync));
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



