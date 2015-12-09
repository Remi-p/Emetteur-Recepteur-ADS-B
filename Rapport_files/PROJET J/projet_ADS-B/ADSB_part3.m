%% Hourquebie & Tafroute
clear all;close all;

%% Chargement des exemples de buffer
y = load('list_cplx_buffers2.mat');

%% Initialisation de l'affichage de la carte
 % La fonction plot_google_map affiche des longitudes/lattitudes en degr? d?cimaux,
MER_LON = -0.710648; % Longitude de l'a?roport de M?rignac
MER_LAT = 44.836316; % Latitude de l'a?roport de M?rignac
figure(1);
plot(MER_LON,MER_LAT,'.r','MarkerSize',20);% On affiche l'a?roport de M?rignac sur la carte
text(MER_LON+0.05,MER_LAT,'Merignac airport','color','r')
plot_google_map('MapType','terrain','ShowLabels',0) % On affiche une carte sans le nom des villes

%% Initialisation des variables
fe = 4*10^6;
Ds = 1*10^6;
Reg_in = [];
Reg_out = [];
lon_ref = -0.710648; % Longitude de l'a?roport de M?rignac
lat_ref = 44.836316; % Latitude de l'a?roport de M?rignac
registre = struct('adresse',[],'format',[],'type',[],'nom',[],'altitude',[],'timeFlag',[],'cprFlag',[],'latitude',[],'longitude',[],'trajectoire',[]);

%% On applique notre fonction sur chaque buffer
for i = 1:22
    yl = abs(y.list_cplx_buffers(i,:));
    [ Reg_out ] = Tafroute_Hourquebie( Reg_in, yl, fe, Ds, lon_ref, lat_ref );
    Reg_in = Reg_out;
end

%% Affichage des avions sur la carte
hold on
for j=1:length(Reg_in)
    if Reg_in(j).trajectoire ~= 0 
        PLANE_LON = Reg_in(j).trajectoire(1,:); % Longitude de l'avion
        PLANE_LAT = Reg_in(j).trajectoire(2,:); % Latitude de l'avion
    else
        PLANE_LON = Reg_in(j).longitude; % Longitude de l'avion
        PLANE_LAT = Reg_in(j).latitude; % Latitude de l'avion
    end
        hold all
        plot(PLANE_LON,PLANE_LAT,'+','MarkerSize',8);
        Id_airplane=Reg_in(j).adresse; % Adresse de l'avion
        text(PLANE_LON(1)+0.05,PLANE_LAT(1),Id_airplane,'color','b');
end