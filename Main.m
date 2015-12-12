%% =================== Communications numeriques ==================== %%
%  Gourdel Thibaut                                           . \|/ /,  %
%  Perrot Remi           ===================                 \\`''/_-- %
%  TS226                 | Travail sur des |          Bordeaux INP --- %
%  Decembre 2015         | donnees reelles |          ENSEIRB  ,..\\`  %
%                        ===================          MATMECA / | \\`  %
% ==================================================================== %

clear all; close all; clc;

global verbose;

registre = struct('adresse', [], 'format', [], 'type', [], 'nom', [], ...
                  'timeFlag', [], 'cprFlag', [], ...
                  'positions', [], 'velocity', []);

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

[trames, decalages] = get_trames( buffer, preambule, ...
    Te, Fse, pa, seuil_empirique, taille_trame_canal, h );

fprintf('Il y a %i pics de correlation.\n', length(decalages));
fprintf('Nous avons trouve %i trame(s) valide(s).\n', size(trames, 2));

for i=1:size(trames,2)
    if verbose;cprintf('_blue', 'Trame %i\n', i);end
	registre = bit2registre(trames(:,i), registre);
end

registre

%planes_on_map( registre.positions, registre.adresse );
