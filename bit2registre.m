function [ registre ] = bit2registre( trame, registre_old, varargin )
% BIT2REGISTRE Extrait les informations du vecteur binaire et renvoie le
%              registre mis a jour seulement si le CRC ne detecte pas
%              d'erreur
%
%   Prend en argument un vecteur de 112 bits et un registre a mettre a 
%   jour avec un registre sous la forme d'une structure.
%   Ainsi qu'un varargin pour des parametres eventuels

% ---- Parametres variables
checkcrc = true;

nVar = length(varargin);

if (nVar ~= 2 & nVar > 0)
    error('Arguments incorrects');
else if nVar == 2
     switch varargin{1}
        case 'CRC'
            checkcrc = varargin{2};
         otherwise
            error('Le type de parametre est inconnu');
     end
end



global verbose;

registre = registre_old;
% defined by x^4+x^3+x^2+x+1:
% Kind of enum
message = struct('identification',1, ...
				 'surface_pos',2, ...
				 'airborne_pos',3, ...
				 'airborne_vel', 4);

if checkcrc
    h = crc.detector([1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1]);
    [outdata err] = detect(h, trame);
    if verbose;cprintf('green','\tCRC correct\n');end
end

% S'il n'y a pas d'erreur dans la sequence
if ~checkcrc | err == 0
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
                        if verbose;fprintf('\tPlane already in database -> OACI : %s\n', AA{:});end
                    end
                end
                % Si l'avion n'existe pas dans la structure
                if index == -1
                   if verbose;fprintf('\tNew plane -> OACI : %s\n', AA{:});end
                   index = length(registre.adresse) +1;
                   registre = newplane2registre(registre, AA, index);
                end
            else
                if verbose;fprintf('\tFirst plane -> OACI : %s\n', AA{:});end
                index = 1;
                registre.adresse = [registre.adresse AA];
                registre.positions{index} = [];
                registre.update(index) = 0;
                registre.velocity(index)  = 0;
                registre.nom  = {};
                registre.altitude(index) = 0;
                registre.head(index) = 0;
                
            end
            
            % Format
            registre.format(index) = DF;
            %% ******* Datas ********
            datas = trame(33:88,1);

            % Format Type Code (FTC)
            FTC = b2d(extract(datas, 1, 1,5));
            registre.type(index) = FTC;

                switch type_message(FTC)

                    case message.identification
                        if verbose;fprintf('\tIdentification for %s\n', AA{:});end
                        % Si l'identification n' pas ete faite
                        if ~isempty(registre.nom)
                            % Name
                            name = extract( datas, 1 , 9 , 56);
                            name = sprintf('%d', name);
                            name = decode_name(name);
                            registre.nom{index} = name;
                        else
                            if verbose;fprintf('\tIdentification already done for %s\n', AA{:});end
                        end
                            
                    case message.airborne_pos
                        if verbose;fprintf('\tAirborne position for %s\n', AA{:});end
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
                        if verbose;fprintf('\tSurface position for %s\n', AA{:});end
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
                        registre.positions{index}{end+1} = [ latitude longitude ];
                        
                        
                        
                    case message.airborne_vel

                        %velocity
                        if verbose;fprintf('\tVelocity and head for %s\n', AA{:});end
                        vel_mes = extract(datas, 1, 14, 35);
                        [velocity, head] = decode_velocity( vel_mes );
                        registre.velocity(index) = velocity;
                        registre.head(index) = head;
                        
                    otherwise
                end
            else
            if verbose;cprintf('err', '\tPas un message ADSB -> debug code DF : %d\n', DF); end
                
            end
        end
else
    if verbose;cprintf('err','Le CRC detetcte une/des erreurs');end
end
end

