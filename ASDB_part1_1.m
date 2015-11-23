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

% g(t) le filtre de mise en forme
g = ones(1, (Fse)) * 0.5;
g(Fse/2:Fse) = - g(Fse/2:Fse);

%% ========================================= Calculs ======================

% Generation de la sequence binaire ([imin, imax], pas, Nbe de symbole)
sb = randi([0, 1], 1, lngr);

% Modulation de phase (donnee, nombre de symboles, phase)
% (passage en Ak = +1 et -1)
ss = pammod(sb, 2, 0);

% On surechantillonne le signal
ss_sur = upsample(ss, Fse);

% Convolution du signal ss(t) et g(t)
sl = conv(ss_sur, g) + 0.5;

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

