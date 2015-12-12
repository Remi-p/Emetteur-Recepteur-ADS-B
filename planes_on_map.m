function [] = planes_on_map( positions, adresse )
% planes_on_map Affiche les avions et leur trajectoire sur une carte 
%               google map


%% La fonction plot_google_map affiche des longitudes/lattitudes en degre decimaux,
MER_LON = -0.710648; % Longitude de l'aeroport de Merignac
MER_LAT = 44.836316; % Latitude de l'aeroport de Merignac

figure(1);
plot(MER_LON,MER_LAT,'.r','MarkerSize',20);% On affiche l'aeroport de Merignac sur la carte
text(MER_LON+0.05,MER_LAT,'Merignac airport','color','r')
plot_google_map('MapType','terrain','ShowLabels',0) % On affiche une carte sans le nom des villes

%% Avions

    for ind=1:size(adresse,2)
        for k=1:length(positions{ind})

        p = positions{ind}{k};

            if k ==1
                plot(p(2), p(1),'.b','MarkerSize',20); 
                text(p(2)+0.1, p(1),adresse{ind},'color','b');
            else
                plot(p(2), p(1),'+b','MarkerSize',10)
            end

        end
    end
    
xlabel('Longitude en degres');
ylabel('Lattitude en degres');

hold on;

end