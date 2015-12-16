function [] = planes_on_map( positions, adresse, type )
% planes_on_map Affiche les avions et leur trajectoire sur une carte 
%               google map
%   type : "Initialisation" : pr?pare la carte
%          Autre : affiche la position des avions entr? en param?tre

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

drawnow

end