%% =================== Communications numeriques ==================== %%
%  Gourdel Thibaut                                           . \|/ /,  %
%  Perrot Remi            =================                  \\`''/_-- %
%  TS226                  | 5.2 Travail   |           Bordeaux INP --- %
%  Decembre 2015          |   a realiser  |           ENSEIRB  ,..\\`  %
%                         =================           MATMECA / | \\`  %
% ==================================================================== %

clc; close all; clear all;

global verbose;
verbose = false;

% Initialisations liees a la carte :
planes_on_map_init();
display_plot = [];
display_text = [];
display_velocity = [];

registre = struct('adresse', [], 'format', [], 'type', [], 'nom', [], ...
                  'timeFlag', [], 'cprFlag', [], ...
                  'positions', [], 'velocity', []);

% Trames fournies dans le zip du projet
load('trames_20141120.mat')

for i=1:size(trames_20141120,2)
    if verbose;cprintf('_blue', 'Trame %i\n', i);end
	registre = bit2registre(trames_20141120(:,i), registre);
end

registre

% Affichage des points
[registre, display_plot, display_text, display_velocity] = planes_on_map( registre, display_plot, display_text, display_velocity);
% display_velocity est ici inutile car il n'y a aucune trame de vitesse
% dans le fichier trames_20141120.mat
