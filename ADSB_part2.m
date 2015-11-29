clc
close all
clear all
       
registre = struct('adresse', [], 'format', [], 'type', [], 'nom', [], ...
                  'altitude', [], 'timeFlag', [], 'cprFlag', [], ...
                  'latitude', [], 'longitude', [], 'trajectoire', [], 'velocity', []);

load('trames_20141120.mat')

%% La fonction plot_google_map affiche des longitudes/lattitudes en degr?? d??cimaux,
MER_LON = -0.710648; % Longitude de l'aeroport de Merignac
MER_LAT = 44.836316; % Latitude de l'aeroport de Merignac

registre = bit2registre(trames_20141120(:,i), registre);

%~ figure(1);
%~ plot(MER_LON,MER_LAT,'.r','MarkerSize',20);% On affiche l'aeroport de Merignac sur la carte
%~ text(MER_LON+0.05,MER_LAT,'Merignac airport','color','r')
%~ plot_google_map('MapType','terrain','ShowLabels',0) % On affiche une carte sans le nom des villes
%~ 
%~ for i=1:21
	%~ registre = bit2registre(trames_20141120(:,i), registre);
    %~ 
    %~ plot(registre.longitude, registre.latitude,'.b','MarkerSize',20);% On affiche l'aeroport de Merignac sur la carte
	%~ 
%~ end
%~ 
%~ xlabel('Longitude en degres');
%~ ylabel('Lattitude en degres');
%~ 
%~ hold on;
