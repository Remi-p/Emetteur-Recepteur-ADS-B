%% =================== Communications numeriques ==================== %%
%  Gourdel Thibaut                                           . \|/ /,  %
%  Perrot Remi           ===================                 \\`''/_-- %
%  TS226                 | Travail sur des |          Bordeaux INP --- %
%  Decembre 2015         | donnees reelles |          ENSEIRB  ,..\\`  %
%                        ===================          MATMECA / | \\`  %
% ==================================================================== %

clear all; close all; clc;

% Buffer de Simon
buff = load('fichierbuffer1.mat');

%% ================== Initialisation des variables =================== %
Rs = 4e6; % Le rythme d'echantillonnage (pas plus de 4Mhz)
Te = 1/Rs;

Rb = 1e6; % debit binaire
Ts = 1/Rb;

% Permet notamment de faire disparaitre le decalage frequentiel
buffer = abs(buff.cplxBuffer);

Fse = Ts/Te; % Sur-echantillonnage

taille_trame = 112; % Taille d'une trame
preambule = get_preambule(Ts, Fse);

% Taille d'une trame au rythme Te
taille_trame_canal = taille_trame * Fse;

seuil_empirique = 0.75;

% Le decalage est calcule pour chaque trame estimee
% decalage_ampl = 0.5;

% CRC
h = crc.detector([1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1]);

% ------------------------------------- Filtres
% p(t) le filtre de mise en forme
p = - ones(1, (Fse)) * 0.5;
p(Fse/2:Fse) = - p(Fse/2:Fse);
% Normalisation :
p = p ./ sqrt(sum(p.^2));

% Filtre de reception : Pour maximiser le rapport signal sur bruit,
% on prend pa(t) = p*(-t)
pa = fliplr(p);

%% =========================================================== Calculs ===

% for i = -10:10
i = 0;

[trames, decalages] = get_trames( buffer, preambule, ...
    Te, Fse, pa, seuil_empirique, taille_trame_canal, h, i );

fprintf('(%i) : %i\n', i, size(trames, 2));

% end

% [275568,350456,384779,394832,394833,418682,429507,432744,432745,452240,452241,592132,592133,737796,782374,782832,874209,885876,908568,910897,910898,911320,915827,915828,929001,960773,985710,985711,1002170,1007879,1035766,1078895,1102453,1128181,1151125,1159634,1161084,1207279,1235953,1256484,1256485,1355762,1355763,1433263,1481681,1481921,1520685,1531365,1531605,1581286,1598534,1629964,1630204,1646998,1664834,1664835,1679308,1682813,1693776,1719486,1728486,1728726,1744464,1777176,1777177,1779171,1779172,1818978,1826924,1826925,1827855,1827856,1862677,1875589,1875590,1893829,1922227,1925178,1929498,1974163,1992029]