function [registre, display_plot, display_text, display_velocity] = planes_on_map( registre, display_plot, display_text, display_velocity )
% PLANES_ON_MAP Affiche les avions et leur trajectoire sur une carte 
%               google map
%   registre : registre contenant les informations vis-a-vis des avions
%   display_plot :
%   display_text :
%   display_velocity : 

%% Avions

for ind=1:size(registre.adresse,2)
    
    for k=1:length(registre.positions{ind})

        % derniere position de l'avion
        curr_plane_pos = registre.positions{ind}{k};
        
        % nombre de positions enregistre pour cet avion
        nb_positions = length(registre.positions{ind});

        if registre.update(ind) == 0;
            if k == nb_positions
                if registre.head(ind) == 0;
                    display_plot{ind} = plot(curr_plane_pos(2), curr_plane_pos(1),'.c','MarkerSize',20); 
                else
                   [display_plot{ind} display_velocity{ind}] = display_head( curr_plane_pos, registre.head(ind), registre.velocity(ind) );
                end
                
                display_text{ind} = text(curr_plane_pos(2)+0.1, curr_plane_pos(1),registre.adresse{ind},'color','r', 'BackgroundColor','white', 'EdgeColor','black');
                registre.update(ind) = k;
            else % sinon
                plot(curr_plane_pos(2), curr_plane_pos(1),'.b','MarkerSize',5)
            end
        
        elseif registre.update(ind) < nb_positions
            % si c'est la derniere position
            if k == nb_positions
                
                set(display_plot{ind}, 'Visible', 'off');
                set(display_text{ind}, 'Visible', 'off');
                set(display_velocity{ind}, 'Visible', 'off');
                
                for m=length(registre.update(ind)):nb_positions
                    
                    p = registre.positions{ind}{m};
                    plot(p(2), p(1),'.b','MarkerSize',5)
                end
                 if registre.head(ind) == 0;
                    display_plot{ind} = plot(curr_plane_pos(2), curr_plane_pos(1),'.c','MarkerSize',20); 
                 else
                     
                 [display_plot{ind} display_velocity{ind}] = display_head( curr_plane_pos, registre.head(ind), registre.velocity(ind) );

                 end
                display_text{ind} = text(curr_plane_pos(2)+0.1, curr_plane_pos(1),registre.adresse{ind},'color','r','BackgroundColor','white', 'EdgeColor','black');
                registre.update(ind) = registre.update(ind)+1;
                

            else % sinon
                plot(curr_plane_pos(2), curr_plane_pos(1),'.b','MarkerSize',5)
            end
        end
    end
end

drawnow

end