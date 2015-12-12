function [ justes, decalages ] = get_trames( bufferabs, preambule, Te, Fse, pa, seuil, lg_trame_canal, h, todelete )
%GET_TRAMES Retourne les trames supposees justes du buffer
%   bufferabs : abs(buffer)
%   preambule : preambule
%   Te, Fse : temps d'echantillonnage, sur-echantillonnage
%   pa : (ga) filtre adapte
%   seuil : seuil determinant une correlation suffisante
%   lg_trame_canal : longueur de la trame au rythme Te
%   h : CRC

% Enregistrement des trames probablement justes
justes = [];

%% ======================== Recherche des trames ====================== %

% On calcule tous les indices qui nous interessent en une seule fois.
decalages = indices_fin_preamb( bufferabs, preambule, lg_trame_canal, Te, seuil );

for i = 1 : length(decalages)
    
    % Indices de la trame a la sortie du canal :
    indices = decalages(i) + (1:lg_trame_canal);
    
    trame_cod = bufferabs( indices + todelete );  
    
    trame_decod = decod(trame_cod, mean(trame_cod), pa, Fse);
    
    % Verification du CRC :
    [outdata err] = detect(h, trame_decod');
    
    if (err == 0)
        % Enregistrement de la trame
        justes(:, end+1) = trame_decod;
    end
    
end

end

