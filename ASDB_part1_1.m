%% =================== Communications numeriques ==================== %%
%  Gourdel Thibaut                                           . \|/ /,  %
%  Perrot Remi            =================                  \\`''/_-- %
%  TS226                  | 4.3 Travail   |           Bordeaux INP --- %
%  Novembre 2015          |  a effectuer  |           ENSEIRB  ,..\\`  %
%                         =================           MATMECA / | \\`  %
% ==================================================================== %

clear all; close all; clc;

%% ================================= Definition des variables =============

% Frequence d'echantillonnage
fe = 20e6;
Te = 1/fe;

% Debit symbole
Ds = 1e6;
Ts = 1/Ds;

% Facteur de surechantillonnage
Fse = Ts/Te;

% Precision des ffts :
Nfft = 512;

% Nombre de bits du message de test
lngr = 1000;

% p(t) le filtre de mise en forme
p = ones(1, (Fse)) * 0.5;
p(Fse/2:Fse) = - p(Fse/2:Fse);

%% ========================================= Calculs ======================

% Generation de la sequence binaire ([imin, imax], pas, Nbe de symbole)
sb = randi([0, 1], 1, lngr);

% Modulation de phase (donnee, nombre de symboles, phase)
% (passage en Ak = +1 et -1)
ss = pammod(sb, 2, 0);

% On surechantillonne le signal
ss_sur = upsample(ss, Fse);

% Convolution du signal ss(t) et g(t)
sl = conv(ss_sur, p) + 0.5;

%% ======================================== Affichage =====================

%                                          Question 11. Allure temporelle %
% ----------------------------------------------------------------------- %

% Nbre de bits a etudier
nb_bit = 25;

figure('Name','Allure temporelle de sl(t)');
x = linspace(0, nb_bit, nb_bit*Fse);
plot(x, sl(1:nb_bit*Fse));
xlabel('bits'); ylabel('Signal sl(t)');
% Choix de l'axe
V=axis;
axis([V(1) V(2) 0 1.1]);
% Graduations :
set(gca,'XTick', 1:nb_bit);
set(gca, 'YTick', [0 1]);
grid on;

%                                        Question 12. Diagramme de l'oeil %
% ----------------------------------------------------------------------- %

nb_bit = 100;

eyediagram(sl(1:nb_bit*Fse), 2*Ts*fe);
V=axis;
axis([V(1) V(2) -0.1 1.1]);

%                             Question 13. Densite spectrale de puissance %
% ----------------------------------------------------------------------- %

% == Densite spectrale de sl(t)
N = length(sl);
Sl = fft(sl, N); % Transformee de Fourier
dsp_pra = (1/(fe*N)) * (abs(Sl).^2); % Formule de la DSP
f = -fe/2 : fe/N : fe/2-fe/N; % Frequences observees

% == Theorique (basee sur f)
% Tout d'abord, il faut decrire le dirac ; il est au centre des frequences
dirac = zeros(1, N);
dirac(ceil(1/N + 1)) = 1;

% A present, on cree la DSP avec la formule de la question 8 :
dsp_theo = 0.25*dirac + ...
    ((Ts^3 * (f*pi).^2)/16) .* ...
    (sinc((Ts * f) ./ 2)).^4;

figure('Name', 'DSP de sl(t)');

semilogy(f, dsp_pra, 'b');
hold on;
semilogy(f(2:end), dsp_theo(2:end), 'r');
% (la premiere valeur de dsp_theo altere le graph)

legend('DSP pratique', 'DSP theorique');
title('Densite Spectrale de Puissance de sl(t)');
xlabel('Frequence (Hz)');
ylabel('Densite spectrale de puissance (W)');