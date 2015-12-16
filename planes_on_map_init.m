function [ output_args ] = planes_on_map_init( input_args )
%PLANES_ON_MAP_INIT Initialisation de la carte pour l'affichage des avions

fprintf('Initialisation de la carte ... ');

%% La fonction plot_google_map affiche des longitudes/lattitudes en degre decimaux,
MER_LON = -0.710648; % Longitude de l'aeroport de Merignac
MER_LAT = 44.836316; % Latitude de l'aeroport de Merignac

figure(1);
plot(MER_LON,MER_LAT,'.r','MarkerSize',20);% On affiche l'aeroport de Merignac sur la carte
text(MER_LON+0.05,MER_LAT,'Merignac airport','color','r')
plot_google_map('MapType','terrain','ShowLabels',0) % On affiche une carte sans le nom des villes

xlabel('Longitude en degres');
ylabel('Lattitude en degres');

hold on;
% pause(1);

fprintf('Done.\n');

end

