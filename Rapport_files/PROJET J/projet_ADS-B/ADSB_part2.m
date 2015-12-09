%%Hourquebie & Tafroute
clear all;close all;
%% Main
registre = struct('adresse',[],'format',[],'type',[],'nom',[],'altitude',[],'timeFlag',[],'cprFlag',[],'latitude',[],'longitude',[],'trajectoire',[]);
    %% La fonction plot_google_map affiche des longitudes/lattitudes en degr? d?cimaux,
    MER_LON = -0.710648; % Longitude de l'a?roport de M?rignac
    MER_LAT = 44.836316; % Latitude de l'a?roport de M?rignac

    figure(1);
    plot(MER_LON,MER_LAT,'.r','MarkerSize',20);% On affiche l'a?roport de M?rignac sur la carte
    text(MER_LON+0.05,MER_LAT,'Merignac airport','color','r')
    plot_google_map('MapType','terrain','ShowLabels',0) % On affiche une carte sans le nom des villes

    xlabel('Longitude en degr?');
    ylabel('Lattitude en degr?');
    y = load('trames_20141120.mat')

    Reg_in = [];

lon_ref = -0.710648; % Longitude de l'a?roport de M?rignac
lat_ref = 44.836316; % Latitude de l'a?roport de M?rignac
for i=1:21
    vec=y.trames_20141120(:,i)';
    [ registre,error ] = bit2registre( vec,lon_ref,lat_ref );
    if error ==1
        break;
    else
        k = 0;
        for j=1:length(Reg_in)
            if registre.adresse == Reg_in(j).adresse 
                if registre.type >= 1 && registre.type <= 4
                    Reg_in(j).nom = registre.nom
                elseif registre.type >= 9 && registre.type <= 22
                     Reg_in(j).cprFlag = registre.cprFlag;
                     Reg_in(j).altitude =  registre.altitude;
                     Reg_in(j).latitude =  registre.latitude;
                     Reg_in(j).longitude =  registre.longitude;
                     registre.trajectoire = [registre.longitude;registre.latitude];
                     Reg_in(j).trajectoire = [Reg_in(j).trajectoire,registre.trajectoire];
                end
                    k = 1;
            end
        end
        if k == 0
            Reg_in = [Reg_in,registre];
        end
 
end
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
        Id_airplane=Reg_in(j).adresse; % Adresse de l'avion
        plot(PLANE_LON,PLANE_LAT,'MarkerSize',8);
        text(PLANE_LON(1)+0.05,PLANE_LAT(1),Id_airplane,'color','b');
    end