function [ display_plot, display_velocity ] = display_head( velocity, positions)
% DISPLAY_HEAD Affiche la derniere position d'un avion et sa direction par
%              une fleche / ou un point
%   p : position
%   velocity : vitesse de l'avion (depuis les trames de vitesse)
%
% Remarque : Nous avions prealablement calcule la direction vis-a-vis des
%            informations donnees dans les trames. Cependant, ces
%            informations n'etaient pas suffisantes pour l'affichage, nous
%            nous sommes donc replies sur une fleche calculee par rapport
%            aux deux positions precedentes

    
% Taille de la fleche
R = 0.05;

% Positions
p1 = positions{end};

if velocity ~= 0
    display_velocity = text(p1(2)+0.1, p1(1)-0.1,num2str(ceil(velocity)),'color','black');
else
    display_velocity = 0;
end
    
% Le nombre de position n'est pas suffisant
if (length(positions) < 2)
    
    display_plot = plot(p1(2), p1(1),'.c','MarkerSize',20);
    
    return;
    
% Sinon ...
else
    
    diff2 = 0;
    diff1 = 0;
    k = 1;
    
    % Recherche de positions differentes permettant un calcul
    while (diff2 == 0 | diff1 == 0)
        
        % On atteint la fin des positions possibles
        if (length(positions) - k < 1)
            display_plot = plot(p1(2), p1(1),'.c','MarkerSize',20);
            return;
        end
            
        p2 = positions{end-k};

        diff2 = p1(2) - p2(2); %x
        diff1 = p1(1) - p2(1); %y
        
        k = k+1;
    
    end
    
    r = sqrt(diff2^2+diff1^2);
    
    % Position relative de la pointe de la fleche
    u = diff2 * R/r;
    v = diff1 * R/r;
    
    % (Old : calcul de l'angle par rapport au cap)
%     u = 0.05*cosd(head);
%     v = 0.05*sind(head);

     display_plot = vekplot2(p1(2),p1(1),u,v,2,'blue-');

%     display_plot = quiver(x,y,u,v);
%     set(display_plot, 'AutoScale', 'off', ...
%                       'AutoScaleFactor',10 );

%     display_plot = text(p(2),p(1),'\fontsize{22}\color{blue}\uparrow', ...
%                            'horizontalalignment','center', ...
%                            'verticalalignment','bottom');
%     set(display_plot, 'rotation', head);


end
