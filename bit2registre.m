function [ registre ] = bit2registre( trame, registre_old )
% bit2registre Extrait les informations du vecteur binaire et renvoie le
%              registre mis a jour seulement si le CRC ne detecte pas
%              d'erreur
%
%   Prend en argument un vecteur de 112 bits et un registre a mettre a 
%   jour avec un registre sous la forme d'une structure.

% defined by x^4+x^3+x^2+x+1:
% Kind of enum
message = struct('identification',1, ...
				 'surface_pos',2, ...
				 'airborne_pos',3, ...
				 'airborne_vel', 4);

% detection d'erreurs
%~ h = crc.detector([1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1])
%~ [outdata error] = detect(h, trame); 
%~ error 

% S'il n'y a pas d'erreur dans la sequence
if error == 0

    registre = registre_old;

        if(~isempty(trame))

            % Downlink Format (5 first bits)
            DF = b2d(extract(trame, 1, 1, 5));
            registre.format = DF;

            if(DF == 17)

            % ICAO aircraft address (AA)
            AA = b2d(extract(trame, 1, 9,32));
            registre.adresse = AA;

            %% ******* Datas ********
            datas = trame(33:88,1);

            % Format Type Code (FTC)
            FTC = b2d(extract(datas, 1, 1,5));
            registre.type = FTC;

                switch type_message(FTC)

                    case message.identification

                        % Name
                        name = extract( datas, 1 , 9 , 56);
                        name = sprintf('%d', name);
                        name = decode_name(name);
                        registre.nom = name;

                    case message.airborne_pos

                        % Altitude 
                        Al = decode_altitude(extract(datas, 1, 9, 20));
                        registre.altitude = Al;

                        % timeFlag
                        TFlag = b2d(extract(datas, 1, 21, 21));
                        registre.timeFlag = TFlag;

                        % cprFlag
                        cprFlag = b2d(extract(datas, 1, 22, 22));
                        registre.cprFlag = cprFlag;

                        % latitude & lonitude
                        lat = b2d(extract(datas, 1, 23, 39));
                        lon = b2d(extract(datas, 1, 40, 56));
                        [ latitude longitude ] = decode_coordonnees(cprFlag, lat, lon);

                        registre.latitude = latitude;
                        registre.longitude = longitude;

                    case message.surface_pos

                        % timeFlag
                        TFlag = b2d(extract(datas, 1, 21, 21));
                        registre.timeFlag = TFlag;

                        % cprFlag
                        cprFlag = b2d(extract(datas, 1, 22, 22));
                        registre.cprFlag = cprFlag;

                        % latitude & lonitude
                        lat = b2d(extract(datas, 1, 23, 39));
                        lon = b2d(extract(datas, 1, 40, 56));
                        [ latitude longitude ] = decode_coordonnees(cprFlag, lat, lon);
                        
                        registre.latitude = latitude;
                        registre.longitude = longitude;

                    case message.airborne_vel

                        % velocity
                        vel_mes = extract(datas, 1, 14, 35);
                        velocity = decode_velocity( vel_mes );
                        registre.velocity = velocity;
                        
                    otherwise
                    
                    
                end
            end
        end
end
end

