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

seuil_empirique = 0.75;

decalage_ampl = 0.5;

% p(t) le filtre de mise en forme
p = - ones(1, (Fse)) * 0.5;
p(Fse/2:Fse) = - p(Fse/2:Fse);
% Normalisation :
p = p ./ sqrt(sum(p.^2));

% Filtre de reception : Pour maximiser le rapport signal sur bruit,
% on prend pa(t) = p*(-t)
pa = fliplr(p);

%% ======================== Recherche des trames ====================== %

% MODIF
buffer = abs(buffer);

% Numero de trames
nb = 1;

h = crc.detector([1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1]);

% trouve = [];
% 
% trames = [];
% 
% post_canal = decod(buffer, 0, pa, Fse);
% % TMP : Recherche des solutions exactes
% for i = 1: length(post_canal) - taille_trame -1
%     
%     [outdata err] = detect(h, transpose(post_canal(i:i + taille_trame - 1)));
%     
%     if err == 0
%         %fprintf('Trouv : %i\n', i);
%         trouve(end+1) = i;
% %         trames(i, :) = decod(i:i + taille_trame - 1);
%     end
%     
% end
% trouve = trouve * Fse; % Adapatation ?
% fprintf('Fin!');
% return;

% Aucune modif
trames_est0 = [       275568,350456,394832,              429507,432744,432745,              737796,782374,874209,885876,910897,911320,915828,960773,985710];
% - mean/4
trames_est1 = [265780,275568,350456,394832,394833,418682,429507,432744,432745,452240,452241,737796,782374,874209,885876,910897,911320,915828,960773,985710];
% - mean/2
trames_est2 = [       275568,350456,394832,              429507,432744,432745,452240,592133,737796,782374,       885876,910897,911320,915828,960773,985710];
% /40
trames_est2 = [       275568,350456,394832,              429507,432744,432745,              737796,782374,874209,885876,910897,911320,915828,960773,985710];

% trames = [];
% for i = trames_est1
%     
%     if (find(trouve == i) > 0)
%         fprintf('%i => Correspondance\n', i);
%     else
%         [val, ind] = min(abs(trouve - i));
%         fprintf('%i => Plus proche : %i [%i]\n', i, val+i, val);
%         trames(end+1, :) =  post_canal((i + ...
%               (1:taille_trame) ));
%     end
%     
% end

% 265780 => Plus proche : 267844 [2064]
% 275568 => Plus proche : 276020 [452]
% 350456 => Plus proche : 350676 [220]
% 394832 => Plus proche : 395412 [580]
% 394833 => Plus proche : 395414 [581]
% 418682 => Plus proche : 418912 [230]
% 429507 => Plus proche : 430476 [969]
% 432744 => Plus proche : 433508 [764]
% 432745 => Plus proche : 433508 [763]
% 452240 => Plus proche : 452468 [228]
% 452241 => Plus proche : 452468 [227]
% 737796 => Plus proche : 738248 [452]
% 782374 => Plus proche : 782828 [454]
% 874209 => Plus proche : 874660 [451]
% 885876 => Plus proche : 886108 [232]
% 910897 => Plus proche : 911442 [545]
% 911320 => Plus proche : 911776 [456]
% 915828 => Plus proche : 916308 [480]
% 960773 => Plus proche : 961004 [231]
% 985710 => Plus proche : 986176 [466]

% On calcule tous les indices qui nous interessent en un seul coup.
decalages = indices_fin_preamb( buffer, preambule, Te, seuil_empirique );
% decalages = trames_est1;

% for i = decalages
%     
%     indices = (i + ...
%              (1:taille_trame_canal + length(preambule)) );
%     figure;
%     plot(buffer(indices));
%     hold on;
%     plot(preambule, 'g');
%     
% end

% decalages = trames_est1;

err_min = 1;
justes = [];


k = 0;
tmp=length(decalages);
for i = 1 : length(decalages)
    
    indices = (decalages(i)-1 + ...
             (1:taille_trame_canal) );
    trame_cod = buffer( indices );  
    trames(:, nb) = decod(trame_cod, mean(trame_cod), pa, Fse);
    nb = nb +1;
    
    [outdata err] = detect(h, trames(1:end, nb-1));
    err_min = min(err, err_min);
    
    if (err == 0)
        
        justes(:, end+1) = trames(:, nb-1);
        
    end
    
    if (mod(k, 1000) == 0)
        fprintf('%i / %i\n', k, tmp);
    end
    
    k = k+1;
    
    % \_ to delete
end

size(justes, 2)

err_min