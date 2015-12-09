function [ registre,error ] = bit2registre( vec,lon_ref,lat_ref )

% Initialisation des variables
registre = struct('adresse',[],'format',[],'type',[],'nom',[],'altitude',[],'timeFlag',[],'cprFlag',[],'latitude',[],'longitude',[],'trajectoire',[]);
Nz = 15;
Nb = 17;

registre.format = bin2dec(num2str(vec(1:5)));
registre.adresse = dec2hex(bin2dec(regexprep(num2str(vec(9:32)),'[^\w'']','')));
registre.type =  bin2dec(num2str(vec(33:37)));

% Message d'identification
if registre.type >= 1 && registre.type <= 4
    for i=41:6:83
        % Lettre
        if bin2dec(num2str(vec(i:i+5)))<=26 && bin2dec(num2str(vec(i:i+5)))>=1
            registre.nom = [registre.nom,char(bin2dec(num2str(vec(i:i+5)))+64)];
        % Chiffre
        elseif bin2dec(num2str(vec(i:i+5)))<=57 && bin2dec(num2str(vec(i:i+5)))>=48
            registre.nom = [registre.nom,char(bin2dec(num2str(vec(i:i+5))))];
        end
    end
% Message de position en vol
elseif registre.type >= 9 && registre.type <= 22
    %Indicateur de format CPR
    registre.cprFlag=vec(54);
    % Altitude
    ra= vec(41:52);
    ra(:,8)=[];
    registre.altitude= bin2dec(num2str(ra))*25-1000;
    
    % Latitude
    rlat = vec(55:71);
    LAT =  bin2dec(num2str(rlat));
    Dlati = 360/(4*Nz-registre.cprFlag);
    j=floor(lat_ref/Dlati)+floor(1/2+(lat_ref-(Dlati*floor(lat_ref/Dlati)))/Dlati-LAT/2^(Nb));
    registre.latitude = Dlati*(j+LAT/2^(Nb));
    
    % Longitude
    rlon = vec(72:88);
    LON = bin2dec(num2str(rlon));
    if cprNL(registre.latitude)-registre.cprFlag>0
        Dloni = 360/(cprNL(registre.latitude)-registre.cprFlag);
    elseif cprNL(registre.latitude)-registre.cprFlag == 0
        Dloni = 360;
    end
    m=floor(lon_ref/Dloni)+floor(1/2+(lon_ref-(Dloni*floor(lon_ref/Dloni)))/Dloni-LON/2^(Nb));
    registre.longitude = Dloni*(m+LON/2^(Nb));
end
% CRC
% Polynome générateur
p=[1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];
H=crc.detector(p);
[outdata error] = detect(H,vec');

end

