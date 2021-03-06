function [ lat lon ] = decode_coordonnees( cprFlag, LAT, LON )
%DECODE_COORDONNEES Decode les latitude et longitude depuis le cprFlag et 
%                   les sequences encodee en CPR de la trame correspondant 
%                   a la latitude et longitude
%   LAT : latitude issue de la trame
%   LON : longitude issue de la trame
%   cprFlag : boulean issue de la trame

%% Latitude
Nz = 15; % nb de lat geographiques considerees entre equateur et un pole
Nb = 17; % nb de bits constituants le registre de latitude

% Coordonees reference de l'antenne (ici l'enseirb)
LATref = 44.8067;
LONref = -0.605744;

% Etape 1
Dlati = 360 / (4 * Nz - cprFlag);

% Etape 2
j = floor(LATref/Dlati) + floor(0.5 + (mod(LATref, Dlati) / Dlati) - (LAT / 2^Nb ));

% Etape 3
lat = Dlati*(j + (LAT/(2^Nb)));

%% Longitude

% Etape 1
if((cprNL(lat) - cprFlag) > 0)
    Dloni = 360/(cprNL(lat) - cprFlag);
else
    Dloni = 360;
end

% Etape 2
m = floor(LONref/Dloni) + floor(0.5 + (mod(LONref, Dloni)/Dloni) - (LON/2^Nb));

% Etape 3
lon = Dloni*(m + (LON/2^Nb));

end

