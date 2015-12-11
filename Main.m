%% =================== Communications numeriques ==================== %%
%  Gourdel Thibaut                                           . \|/ /,  %
%  Perrot Remi            =================                  \\`''/_-- %
%  TS226                  |               |           Bordeaux INP --- %
%  Decembre 2015          |               |           ENSEIRB  ,..\\`  %
%                         =================           MATMECA / | \\`  %
% ==================================================================== %

clear all; close all; clc;

buff = load('fichierbuffer1.mat');
buffer = buff.cplxBuffer;

%% ================== Initialisation des variables =================== %
Rs = 4e6; % Le rythme d'echantillonnage (pas plus de 4Mhz)
Te = 1/Rs;

Rb = 1e6; % debit binaire
Ts = 1/Rb;

Fse = Ts/Te;

taille_trame = 112; % Taille d'une trame
preambule = get_preambule(Ts, Fse);

taille_trame_canal = taille_trame * Fse;

taille_analyse = taille_trame_canal + length(preambule);

iter = ceil(length(buffer) / taille_analyse);

antenna_gain = 40;

max_t = 0;

seuil_empirique = 0.80;

decalage_ampl = 0.5;

% p(t) le filtre de mise en forme
p = - ones(1, (Fse)) * 0.5;
p(Fse/2:Fse) = - p(Fse/2:Fse);

% Filtre de reception : Pour maximiser le rapport signal sur bruit,
% on prend pa(t) = p*(-t)
pa = fliplr(p);

%% ======================== Recherche des trames ====================== %

% On enleve le gain passif de l'antenne
buffer = buffer ./ antenna_gain;

% Nombre de trames
nb = 1;

for i = 1 : iter/4
    
    if i == iter
        trame_a_analyser = buffer((i-1) * taille_analyse : end);
    else
        trame_a_analyser = buffer((i-1) * taille_analyse + 1 : i * taille_analyse);
    end
    
    [dec, t] = est_sync_t( trame_a_analyser, preambule, Te );
    
    if (t > seuil_empirique)
        % On decode la trame
        trame_cod = buffer( ((i-1) * taille_analyse + dec + Fse + length(preambule) + (1:taille_trame_canal) ));
        
        trames(:, nb) = decod(trame_cod, decalage_ampl, pa, Fse);
        nb = nb +1;
    end
    
end

trames