%% =================== Communications numeriques ==================== %%
%  Gourdel Thibaut                                           . \|/ /,  %
%  Perrot Remi           ===================                 \\`''/_-- %
%  TS226                 | Travail sur des |          Bordeaux INP --- %
%  Decembre 2015         | donnees reelles |          ENSEIRB  ,..\\`  %
%                        ===================          MATMECA / | \\`  %
% ==================================================================== %

clear all; close all; clc;

global verbose;
              
%% ================== Initialisation des variables =================== %

registre = struct('adresse', [], 'format', [], 'type', [], 'nom', [], ...
                  'timeFlag', [], 'cprFlag', [], ...
                  'positions', [], 'update', [], 'velocity', [], 'head', []);

% Initialisations liees a la carte :
planes_on_map_init();
display_plot = [];
display_text = [];
display_velocity = [];

Rb = 1e6; % debit binaire
Ts = 1/Rb;

Rs = 4e6; % Le rythme d'echantillonnage (pas plus de 4Mhz)
Te = 1/Rs;

Fse = Ts/Te; % Sur-echantillonnage

taille_trame = 112; % Taille d'une trame
preambule = get_preambule(Ts, Fse);

% Taille d'une trame au rythme Te
taille_trame_canal = taille_trame * Fse;

seuil_empirique = 0.80;

% Le decalage est calcule pour chaque trame estimee
% decalage_ampl = 0.5;

% CRC
% On n'utilise pas la fonction propose par MATLAB pour gagner en temps
% d'execution
%h = crc.detector([1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1]);
p_gen = [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];

% ------------------------------------- Filtres
% p(t) le filtre de mise en forme
p = [-ones(1, Fse/2) ones(1, Fse/2)] / 2;
% p = p / sqrt(sum(p.^2));

% Filtre de reception : Pour maximiser le rapport signal sur bruit,
% on prend pa(t) = p*(-t)
pa = fliplr(p);

%% =========================================================== Calculs ===

% Simulation de temps reel avec les buffers de Simon & Clement
for k = 1:7

    fprintf('\nBuffer #%i\n', k);

    buff = load(sprintf('fichierbuffer%i.mat', k));
    % Permet notamment de faire disparaitre le decalage frequentiel
    buffer = abs(buff.cplxBuffer);

    [trames, decalages] = get_trames( buffer, preambule, ...
        Te, Fse, pa, seuil_empirique, taille_trame_canal, p_gen );

    fprintf('Il y a %i pics de correlation.\n', length(decalages));
    fprintf('Nous avons trouve %i trame(s) valide(s).\n', size(trames, 2));

    for i=1:size(trames,2)
        if verbose; cprintf('_blue', 'Trame %i\n', i); end
        registre = bit2registre(trames(:,i), registre, 'CRC', false);
        % 'CRC' = false permet de ne pas recalculer le CRC (deja fait dans
        % get_trames)
    end


    if mod(k, 2) == 0
        % Mise a jour de la carte
        [registre, display_plot, display_text, display_velocity] = planes_on_map( registre, display_plot, display_text, display_velocity);
    end
%     registre
    clear buff;
    
end