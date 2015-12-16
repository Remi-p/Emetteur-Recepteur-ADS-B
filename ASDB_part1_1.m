%% =================== Communications numeriques ==================== %%
%  Gourdel Thibaut                                           . \|/ /,  %
%  Perrot Remi            =================                  \\`''/_-- %
%  TS226                  | 4.3 Travail   |           Bordeaux INP --- %
%  Decembre 2015          |  a effectuer  |           ENSEIRB  ,..\\`  %
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
Nfft = 2048;

% Nombre de bits du message de test
lngr = 10000;

% p(t) le filtre de mise en forme
p = [ -ones(1, Fse/2) ones(1, Fse/2) ] /2;

%% =========================================== Canal ======================

% Generation de la sequence binaire ([imin, imax], pas, Nbe de symbole)
sb = randi([0, 1], 1, lngr);

% Modulation de phase (donnee, nombre de symboles, phase)
% (passage en Ak = +1 et -1)
% ss = pammod(sb, 2, 0);
ss = sb * 2 -1;

% On surechantillonne le signal
ss_sur = upsample(ss, Fse);

% Convolution du signal ss(t) et g(t)
sl = conv(ss_sur, p) + 0.5;
% sl = filter(p, 1, ss_sur) + 0.5;

%% ========================================== Courbes =====================

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

% == Densite spectrale de sl(t) ---------------

% On commence par "decouper" notre vecteur, pour effectuer un moyennage

% Nombre de lignes pour le moyennage
nbr_lignes = ceil(length(sl) / Nfft);
% Zero-padding
sl_zero = zeros(1, nbr_lignes*Nfft);
sl_zero(1:length(sl)) = sl;
% "Decoupage" du vecteur
sl_mat = reshape(sl_zero, Nfft, nbr_lignes);

% DSP
% Transformee de Fourier
Sl = fft(sl_mat, Nfft);
Sl_moy = mean(abs(Sl), 2);
% On centre la TF
Sl_dec = fftshift(Sl_moy);
% Formule de la DSP
dsp_pra = (1/(fe*Nfft)) * (Sl_dec.^2);

% Frequences observees
f = -fe/2 : fe/Nfft : fe/2-fe/Nfft;

% == Theorique (basee sur f) ------------------

% Tout d'abord, il faut decrire le dirac ; il est au centre des frequences
dirac = zeros(1, Nfft);
dirac(ceil(Nfft/2 + 1)) = 1;

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