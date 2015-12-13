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
              
%% La fonction plot_google_map affiche des longitudes/lattitudes en degre decimaux,
% MER_LON = -0.710648; % Longitude de l'aeroport de Merignac
% MER_LAT = 44.836316; % Latitude de l'aeroport de Merignac
% 
% figure(1);
% plot(MER_LON,MER_LAT,'.r','MarkerSize',20);% On affiche l'aeroport de Merignac sur la carte
% text(MER_LON+0.05,MER_LAT,'Merignac airport','color','r')
% plot_google_map('MapType','terrain','ShowLabels',0) % On affiche une carte sans le nom des villes
%               
% xlabel('Longitude en degres');
% ylabel('Lattitude en degres');
% 
% hold on;
% pause(1);     
              
%% ================== Initialisation des variables =================== %
Rs = 4e6; % Le rythme d'echantillonnage (pas plus de 4Mhz)
Te = 1/Rs;

Rb = 1e6; % debit binaire
Ts = 1/Rb;

Fse = Ts/Te; % Sur-echantillonnage

taille_trame = 112; % Taille d'une trame
preambule = get_preambule(Ts, Fse);

% Taille d'une trame au rythme Te
taille_trame_canal = taille_trame * Fse;

seuil_empirique = 0.85;

% Le decalage est calcule pour chaque trame estimee
% decalage_ampl = 0.5;

% CRC
% On n'utilise pas la fonction propose par MATLAB pour gagner en temps
% d'execution
%h = crc.detector([1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1]);
p_gen = [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];

% ------------------------------------- Filtres
% p(t) le filtre de mise en forme
p = - ones(1, (Fse)) * 0.5;
p(Fse/2:Fse) = - p(Fse/2:Fse);

% Filtre de reception : Pour maximiser le rapport signal sur bruit,
% on prend pa(t) = p*(-t)
pa = fliplr(p);

%% =========================================================== Calculs ===

% Simulation de temps reel avec les buffers de Simon & Clement
for k = 1:7
    
    fprintf('Buffer #%i\n\n', k);
    
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

    registre
	%planes_on_map( registre.positions, registre.adresse );
    clear buff;
    
end

