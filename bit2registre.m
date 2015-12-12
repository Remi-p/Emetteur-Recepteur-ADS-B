function [ registre ] = bit2registre( trame, registre_old )
% bit2registre Extrait les informations du vecteur binaire et renvoie le
%              registre mis a jour seulement si le CRC ne detecte pas
%              d'erreur
%
%   Prend en argument un vecteur de 112 bits et un registre a mettre a 
%   jour avec un registre sous la forme d'une structure.
registre = registre_old;
% defined by x^4+x^3+x^2+x+1:
% Kind of enum
message = struct('identification',1, ...
				 'surface_pos',2, ...
				 'airborne_pos',3, ...
				 'airborne_vel', 4);

h = crc.detector([1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1]);
[outdata err] = detect(h, trame);
err = 0;

% S'il n'y a pas d'erreur dans la sequence
if err == 0
        if(~isempty(trame))
            
            % Downlink Format (5 first bits)
            DF = b2d(extract(trame, 1, 1, 5));
            %registre.adresse =  [registre.adresse AA];
            
            if(DF == 17)

            % ICAO aircraft address (AA)
            AA = cellstr(dec2hex(b2d(extract(trame, 1, 9,32))));
        
            if ~isempty(registre.adresse)
                index = -1;
                for i=1:length(registre.adresse)
                    if (strcmpi(registre.adresse{i},AA) == 1)
                        index = i;
                        fprintf('Avion deja dans la base');
                    end
                end
                % Si l'avion n'existe pas dans la structure
                if index == -1
                   L = length(registre.adresse)
                   index = length(registre.adresse) +1;
                   registre = newplane2registre(registre, AA, index);
                end
            else
                fprintf('Premier avion');
                index = 1;
                registre.adresse = [registre.adresse AA];
                registre.positions{index} = [];
                registre.velocity(index)  = 0;
                registre.nom  = {};
                
            end
            
            % Format
            registre.format(index) = DF;
            
            index
            %% ******* Datas ********
            datas = trame(33:88,1);

            % Format Type Code (FTC)
            FTC = b2d(extract(datas, 1, 1,5));
            registre.type(index) = FTC;

                switch type_message(FTC)

                    case message.identification
                        fprintf('Trame Identification');
                        % Si l'identification n' pas ete faite
                        if isempty(registre.nom)
                            % Name
                            name = extract( datas, 1 , 9 , 56);
                            name = sprintf('%d', name);
                            name = decode_name(name);
                            registre.nom{index} = name;
                        else
                            fprintf('Identification deja faite');
                        end
                            
                    case message.airborne_pos

                        % Altitude 
                        Al = decode_altitude(extract(datas, 1, 9, 20));
                        registre.altitude(index) = Al;

                        % timeFlag
                        TFlag = b2d(extract(datas, 1, 21, 21));
                        registre.timeFlag(index) = TFlag;

                        % cprFlag
                        cprFlag = b2d(extract(datas, 1, 22, 22));
                        registre.cprFlag(index) = cprFlag;

                        % latitude & lonitude
                        lat = b2d(extract(datas, 1, 23, 39));
                        lon = b2d(extract(datas, 1, 40, 56));
                        [ latitude, longitude ] = decode_coordonnees(cprFlag, lat, lon);
                        
                        registre.positions{index}{end+1} = [ latitude longitude ];

                    case message.surface_pos

                        % timeFlag
                        TFlag = b2d(extract(datas, 1, 21, 21));
                        registre.timeFlag(index) = TFlag;

                        % cprFlag
                        cprFlag = b2d(extract(datas, 1, 22, 22));
                        registre.cprFlag(index) = cprFlag;

                        % latitude & lonitude
                        lat = b2d(extract(datas, 1, 23, 39));
                        lon = b2d(extract(datas, 1, 40, 56));
                        [ latitude longitude ] = decode_coordonnees(cprFlag, lat, lon);
                        
                        registre.latitude(index,size(registre.latitude,2)+1) = latitude;
                        registre.longitude(index,size(registre.longitude,2)+1) = longitude;

                    case message.airborne_vel

                        % velocity
                        vel_mes = extract(datas, 1, 14, 35);
                        velocity = decode_velocity( vel_mes );
                        registre.velocity(index) = velocity;
                        
                    otherwise
                end
            end
        end
else
    fprintf('Le CRC detetcte une/des erreurs');
end
end

