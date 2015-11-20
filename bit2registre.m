function [] = bit2registre( trame, registre )
% bit2registre Extrait les informations du vecteur binaire et renvoie le
%              registre mis a jour seulement si le CRC ne detecte pas
%              d'erreur
%
%   Prend en argument un vecteur de 112 bits et un registre a mettre a 
%   jour avec un registre sous la forme d'une structure.

% Kind of enum
message = struct('identification',1, ...
				 'surface_pos',2, ...
				 'airborne_pos',3, ...
				 'airborne_vel', 4);

	if(~isempty(trame))

		% Downlink Format (5 first bits)
		DF = b2d(extract(trame, 1, 1, 5));
		registre.format = DF;
		DF

		if(DF == 17)
	
		% ICAO aircraft address (AA)
		AA = b2d(extract(trame, 1, 9,32));
		registre.adresse = AA;
		AA
		
		%% ******* Datas ********
		datas = trame(33:88,1);

		% Format Type Code (FTC)
		FTC = b2d(extract(datas, 1, 1,5));
		registre.type = FTC;
		FTC
		
			switch type_message(FTC)
			
				case message.identification
				
					% Name
					name = extract( datas, 1 , 9 , 56);
					name = sprintf('%d', name);
					name = decode_name(name);
					registre.nom = name;

					registre	
					
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
                    lat
                    lon = b2d(extract(datas, 1, 40, 56));
                    [ latitude longitude ] = decode_coordonnees(cprFlag, lat, lon);

					registre.latitude = latitude;
                    registre.longitude = longitude;
                    
                    registre
			
				case message.surface_pos
					
				case message.airborne_vel
					
				otherwise
					
			end
		end
	end
end

