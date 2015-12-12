clc
close all
clear all
       
registre = struct('adresse', [], 'format', [], 'type', [], 'nom', [], ...
                  'timeFlag', [], 'cprFlag', [], ...
                  'positions', [], 'velocity', []);
              

              
%load('trames_13.mat')
matrice_binaire2 = [1,0,1;0,1,0;0,0,0;0,1,0;1,1,1;1,1,1;0,0,0;1,1,1;0,0,0;0,0,0;1,1,1;1,1,1;0,0,0;1,1,1;0,0,0;0,0,0;0,0,0;1,1,1;0,0,0;0,0,0;0,0,0;1,1,1;0,0,0;1,1,1;1,1,1;0,0,0;0,0,0;0,0,0;0,0,0;0,0,0;1,1,1;1,1,1;0,0,1;1,1,0;0,1,0;1,1,1;1,1,1;0,0,0;0,0,0;0,1,1;1,1,0;0,1,0;1,0,0;1,1,0;1,0,0;1,0,1;0,1,0;1,1,0;1,0,1;1,1,1;1,1,0;1,0,0;0,1,1;0,1,1;0,1,0;1,1,0;1,0,1;0,0,0;1,0,1;0,0,0;0,0,1;0,0,1;0,0,1;0,0,0;1,0,0;1,0,0;0,0,1;0,0,0;1,0,1;0,0,0;0,0,0;1,0,0;1,0,0;1,0,0;0,0,0;0,0,0;1,0,0;0,0,1;0,0,1;1,0,1;0,0,0;0,0,0;1,0,0;1,0,1;1,0,0;0,0,1;1,0,1;1,0,1;0,0,1;1,0,0;0,0,0;1,0,0;0,0,1;1,0,0;0,0,1;1,0,1;0,0,0;0,0,1;0,0,1;1,0,0;0,0,1;0,0,0;0,0,1;1,0,1;1,0,0;0,0,0;1,0,1;0,0,1;0,0,0;0,0,1;1,0,1;1,0,1];

%% La fonction plot_google_map affiche des longitudes/lattitudes en degre decimaux,
MER_LON = -0.710648; % Longitude de l'aeroport de Merignac
MER_LAT = 44.836316; % Latitude de l'aeroport de Merignac

figure(1);
plot(MER_LON,MER_LAT,'.r','MarkerSize',20);% On affiche l'aeroport de Merignac sur la carte
text(MER_LON+0.05,MER_LAT,'Merignac airport','color','r')
plot_google_map('MapType','terrain','ShowLabels',0) % On affiche une carte sans le nom des villes

%matrice_binaire2 = matrice_binaire(9:120,:);

for i=1:size(matrice_binaire2,2)
    cprintf('_blue', 'Trame %i\n', i);
	registre = bit2registre(matrice_binaire2(:,i), registre);
end

registre

for ind=1:size(registre.adresse,2)
    for k=1:length(registre.positions{ind})
    
    p = registre.positions{ind}{k};
    
        if k ==1
            plot(p(2), p(1),'.b','MarkerSize',20); 
            text(p(2)+0.1, p(1),registre.adresse{ind},'color','b');
        else
            plot(p(2), p(1),'+b','MarkerSize',10)
        end
        
    end
end

xlabel('Longitude en degres');
ylabel('Lattitude en degres');

hold on;
