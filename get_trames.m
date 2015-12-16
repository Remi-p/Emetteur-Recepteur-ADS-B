function [ justes, decalages ] = get_trames( bufferabs, preambule, Te, Fse, pa, seuil, lg_trame_canal, p_gen )
%GET_TRAMES Retourne les trames supposees justes du buffer
%   bufferabs : abs(buffer)
%   preambule : preambule
%   Te, Fse : temps d'echantillonnage, sur-echantillonnage
%   pa : (ga) filtre adapte
%   seuil : seuil determinant une correlation suffisante
%   lg_trame_canal : longueur de la trame au rythme Te
%   p_gen : polynome generateur pour le CRC

% Enregistrement des trames probablement justes
justes = [];

%% ======================== Recherche des trames ====================== %

% On calcule tous les indices qui nous interessent en une seule fois.
decalages = indices_fin_preamb( bufferabs, preambule, lg_trame_canal, Te, seuil );

for i = 1 : length(decalages)
    
    % Indices de la trame a selectionner, a la sortie du canal :
    indices = decalages(i) + (1:lg_trame_canal);
    
    trame_cod = bufferabs( indices );
    
    recentrage = ( max(trame_cod) - min(trame_cod) ) / 2;
    [trame_decod poids] = decod(trame_cod, recentrage, pa, Fse);
    
    % Verification du CRC :
    % On n'utilise pas la fonction propose par MATLAB, pour gagner en temps
    % d'execution
    %[outdata err] = detect(h, trame_decod');
    [outdata err] = crc24(trame_decod, p_gen);
    
    % --------------- Force brut, correction d'une erreur ----------------
    % (inspire de https://github.com/antirez/dump1090/blob/master/dump1090.c fonction fixSingleBitErrors()
    % et https://www.ll.mit.edu/mission/aviation/publications/publication-files/ms-papers/Harman_1998_DASC_MS-13181_WW-18698.pdf
    % pour cibler les bits avec une probabilite elevee d'erreur)
    if err ~= 0
        poids_moy = mean(poids);
        for (j = 1:length(outdata))
            
            % Test uniquement des bits probablement faux
            if (poids(j) < poids_moy)
            
                trame_decod_tmp = trame_decod';

                % Modification d'un bit de poids "faible" :
                trame_decod_tmp(j) = ~trame_decod_tmp(j);

                [outdata_tmp err_tmp] = crc24(transpose(trame_decod_tmp), p_gen);
                
                if err_tmp == 0
                    outdata = outdata_tmp;
                    err = err_tmp;
                    break;
                end
                
            end
        end
    end
    % --------------------------------------------------------------------
        
    
    if (err == 0)
        % Enregistrement de la trame
        justes(:, end+1) = outdata;

        % Test de bon fonctionnement du crc : ----------
        % trame_decod(i) = ~trame_decod(i);
        % 
        % [outdata err] = crc24(trame_decod, p);
        % if (err == 0)
        %     fprintf('L''erreur volontairement ajoutee n''a pas ete detectee !!');
        % end
        % ----------------------------------------------
    end
    
end

end

